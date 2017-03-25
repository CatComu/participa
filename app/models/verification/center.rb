class Verification::Center < ApplicationRecord
  validates :name, :street, :city, presence: true

  has_many :verification_slots, -> { for_center }, class_name: 'Verification::Slot', foreign_key: :verification_center_id

  accepts_nested_attributes_for :verification_slots, allow_destroy: true

  scope :active, -> { all }

  def periods

  end

  def address
    [street, postalcode.presence, city].compact.join(', ')
  end

  def slots_text
    str = ""
    self.verification_slots.order(:starts_at).each do |slot|
      str += slot.starts_at.day.to_s
    end
    str
  end

end
