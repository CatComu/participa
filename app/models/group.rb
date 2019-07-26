class Group < ApplicationRecord
  belongs_to :territory, polymorphic: true

  after_create :add_default_position
  has_many :positions, dependent: :destroy
  has_many :users, through: :positions

  validates :name, presence: true
  validates :location_type, presence: true, if: lambda { |u| u.has_location? }

  enum location_type: [:province, :vegueria, :district, :supra_municipality, :catalan_town]

  attr_accessor :territory_holder

  def location_type_name
    if self.location_type
      I18n.t("location_types.#{self.location_type}", scope: 'activerecord.attributes.group')
    end
  end

  def territory_holder
    "#{location_type}-#{territory_id}"
  end

  def territory_holder=(data)
    if data.present?
      data = data.split("-")
      self.territory_type = data[0].camelcase
      self.territory_id = data[1]
    end
  end

  private
  
  def add_default_position
    Position.create! name: "Ninguno", group: self
  end
end
