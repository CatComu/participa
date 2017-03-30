require 'active_support/concern'
require 'securerandom'

module Verificable
  extend ActiveSupport::Concern

  included do
    belongs_to :verified_by, class_name: "User"
    belongs_to :verified_online_by, class_name: "User"

    has_many :verificated_users, class_name: "User", foreign_key: :verified_by_id
    has_many :verification_slots, class_name: "Verification::Slot"

    has_many :uploads, class_name: "OnlineVerifications::Upload", foreign_key: :verified_id

    accepts_nested_attributes_for :verification_slots, allow_destroy: true

    scope :verifying_presentially, -> do
      joins(:verification_slots).merge(Verification::Slot.presential.active)
    end

    scope :verifying_online, -> do
      joins(:verification_slots).merge(Verification::Slot.online.active)
    end

    scope :presential_verifier_ever, -> do
      joins(:verification_slots).merge(Verification::Slot.presential.past_or_current)
    end

    scope :confirmed_by_sms, -> { not_banned.where.not(sms_confirmed_at: nil) }

    scope :verified, -> { verified_presentially.or(verified_online) }
    scope :unverified, -> { where(verified_by: nil, verified_online_by: nil) }

    scope :verified_presentially, -> { not_banned.where.not(verified_by: nil) }
    scope :unverified_presentially, -> { where(verified_by: nil) }

    scope :verified_online, -> { not_banned.where.not(verified_online_by: nil) }
    scope :unverified_online, -> { where(verified_online_by: nil) }

    scope :voting_right, -> { verified_presentially.or(confirmed_by_sms) }
    scope :online_verification_pending, -> { confirmed_by_sms.unverified_online }
  end

  class_methods do
    def sms_confirmation_period
      3.months
    end
  end

  def verifying_presentially?
    verification_slots.presential.active.any?
  end

  def verifying_online?
    verification_slots.online.active.any?
  end

  def presential_verifier_ever?
    verification_slots.presential.past_or_current.any?
  end

  def unconfirmed_by_sms?
    sms_confirmed_at.nil?
  end

  def confirmed_by_sms?
    return false unless Features.online_verifications? && not_banned?

    !unconfirmed_by_sms?
  end

  def can_change_phone?
    unconfirmed_by_sms? or
      sms_confirmed_at < DateTime.now-self.class.sms_confirmation_period
  end

  def generate_sms_token
    SecureRandom.hex(4).upcase
  end

  def set_sms_token!
    update_attribute(:sms_confirmation_token, generate_sms_token)
  end

  def send_sms_token!
    require 'sms'
    update_attribute(:confirmation_sms_sent_at, DateTime.now)
    SMS::Sender.send_message(unconfirmed_phone, sms_confirmation_token)
  end

  def check_sms_token(token)
    if token == sms_confirmation_token
      if unconfirmed_phone
        update_attribute(:phone, unconfirmed_phone)
        update_attribute(:unconfirmed_phone, nil)

        if not is_verified? and not is_admin?
          filter = SpamFilter.any? self
          if filter
            update_attribute(:banned, true)
            add_comment("Usuario baneado automáticamente por el filtro: #{filter}")
          end
        end
      end
      update_attribute(:sms_confirmed_at, DateTime.now)
      true
    else
      false
    end
  end

  def voting_right?
    confirmed_by_sms? || is_verified_presentially?
  end

  def is_verified?
    is_verified_online? || is_verified_presentially?
  end

  def online_verification_pending?
    return false unless Features.online_verifications? && not_banned?

    confirmed_by_sms? && verified_online_by.nil?
  end

  def is_verified_online?
    return false unless Features.online_verifications? && not_banned?

    confirmed_by_sms? && verified_online_by_id?
  end

  def is_verified_presentially?
    return false unless Features.presential_verifications? && not_banned?

    verified_by_id?
  end

  def verify! user
    update(verified_at: DateTime.now, verified_by: user)
    VerificationMailer.verified(self).deliver_now
  end

  def verify_online! user
    update(verified_online_at: DateTime.now, verified_online_by: user)
  end
end
