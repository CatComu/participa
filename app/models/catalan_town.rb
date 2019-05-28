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
end
