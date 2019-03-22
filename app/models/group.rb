class Group < ApplicationRecord
  after_create :add_default_position
  has_many :positions, dependent: :destroy
  has_many :users, through: :positions

  validates :name, presence: true
  validates :location_type, presence: true, if: lambda { |u| u.has_location? }
  validates :space_type, presence: true, if: lambda { |u| u.has_space? }

  enum location_type: [:territory, :municipality, :entity, :comarcal, :provincial]

  private
  
  def add_default_position
    Position.create! name: "Ninguno", group: self
  end
end
