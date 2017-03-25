# frozen_string_literal: true

class CatalanTown < ApplicationRecord
  self.primary_key = :code

  validates :code,
            :name,
            presence: true,
            uniqueness: true

  validates :comarca_code,
            :comarca_name,
            :vegueria_code,
            :vegueria_name,
            presence: true
end
