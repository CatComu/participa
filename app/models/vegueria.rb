class Vegueria < ApplicationRecord
  belongs_to :province
  has_many :groups, as: :territory
end
