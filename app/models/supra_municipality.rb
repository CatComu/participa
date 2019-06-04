# frozen_string_literal: true

class SupraMunicipality < ApplicationRecord
  has_many :groups, as: :territory
  has_and_belongs_to_many :municipalities, class_name: CatalanTown, join_table: :catalan_towns_supra_municipalities
end
