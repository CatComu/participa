class Province < ApplicationRecord
  has_many :groups, as: :territory
  has_and_belongs_to_many :veguerias
  has_and_belongs_to_many :districts

  has_many :towns, through: :veguerias
  has_many :users, through: :veguerias
end
