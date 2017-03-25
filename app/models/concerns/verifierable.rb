require 'active_support/concern'

module Verifierable
  extend ActiveSupport::Concern

  included do
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
end
