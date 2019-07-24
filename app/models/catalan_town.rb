# frozen_string_literal: true

class CatalanTown < ApplicationRecord

  validates :code,
            :name,
            presence: true,
            uniqueness: true

  validates :comarca_code,
            :comarca_name,
            :vegueria_code,
            :vegueria_name,
            presence: true

  has_many :groups, as: :territory
  has_many :users, foreign_key: "town", class_name: "User", primary_key: "code"
  belongs_to :vegueria, primary_key: "code", foreign_key: "vegueria_code"

end
