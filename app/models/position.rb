class Position < ApplicationRecord
  has_and_belongs_to_many :users
  belongs_to :group
  validates :name, :group, presence: true

  enum position_type: %i[electa convidada assessora]
  delegate :territory, to: :group, allow_nil: true
  delegate :users, to: :territory, allow_nil: true, prefix: true
end
