class Province < ApplicationRecord
  has_many :groups, as: :territory
end
