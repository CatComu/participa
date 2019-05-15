class District < ApplicationRecord
  belongs_to :vegueria
  has_many :groups, as: :territory
end
