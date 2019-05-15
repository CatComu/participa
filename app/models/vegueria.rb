class Vegueria < ApplicationRecord
  has_many :groups, as: :territory

  has_and_belongs_to_many :provinces
  has_and_belongs_to_many :districts
end
