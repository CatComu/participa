class District < ApplicationRecord
  has_many :groups, as: :territory

  has_and_belongs_to_many :veguerias
end
