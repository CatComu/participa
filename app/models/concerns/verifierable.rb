require 'active_support/concern'
require 'securerandom'

module Verifierable
  extend ActiveSupport::Concern

  included do
    belongs_to :verified_by, class_name: "User"
    has_many :verificated_users, class_name: "User", foreign_key: :verified_by_id

    has_many :verification_slots, class_name: "Verification::Slot"

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

    scope :verified, -> { where.not(verified_at: nil) }
    scope :unverified, -> { where(verified_at: nil) }

    scope :verified_presentially, -> { where.not(verified_at: nil, verified_by: nil) }
    scope :unverified_presentially, -> { where(verified_by_id: nil)}

    scope :verified_online, -> { where.not(verified_at: nil, sms_confirmed_at: nil) }
    scope :unverified_online, -> { where(sms_confirmed_at: nil) }
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
    self.sms_confirmed_at.nil?
  end

  def confirmed_by_sms?
    !self.unconfirmed_by_sms?
  end

  def can_change_phone?
    self.unconfirmed_by_sms? or
      self.sms_confirmed_at < DateTime.now-self.class.sms_confirmation_period
  end

  def generate_sms_token
    SecureRandom.hex(4).upcase
  end

  def set_sms_token!
    self.update_attribute(:sms_confirmation_token, generate_sms_token)
  end

  def send_sms_token!
    require 'sms'
    self.update_attribute(:confirmation_sms_sent_at, DateTime.now)
    SMS::Sender.send_message(self.unconfirmed_phone, self.sms_confirmation_token)
  end

  def check_sms_token(token)
    if token == self.sms_confirmation_token
      if self.unconfirmed_phone
        self.update_attribute(:phone, self.unconfirmed_phone)
        self.update_attribute(:unconfirmed_phone, nil)

        if not self.is_verified? and not self.is_admin?
          filter = SpamFilter.any? self
          if filter
            self.update_attribute(:banned, true)
            self.add_comment("Usuario baneado automáticamente por el filtro: #{filter}")
          end
        end
      end
      self.update_attribute(:sms_confirmed_at, DateTime.now)
      true
    else
      false
    end
  end

  def is_verified?
    is_verified_online? || is_verified_presentially?
  end

  def is_verified_online?
    return false unless Features.online_verifications?

    self.confirmed_by_sms?
  end

  def is_verified_presentially?
    return false unless Features.presential_verifications?

    self.verified_by_id?
  end

  def verify! user
    self.update(verified_at: DateTime.now, verified_by: user)
    VerificationMailer.verified(self).deliver_now
  end
end
