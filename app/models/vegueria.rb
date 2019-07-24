class Vegueria < ApplicationRecord
  has_many :groups, as: :territory

  has_and_belongs_to_many :provinces
  has_and_belongs_to_many :districts

  has_many :towns,
    primary_key: "code",
    foreign_key: "vegueria_code",
    class_name: "CatalanTown"

  has_many :users, through: :towns
end
