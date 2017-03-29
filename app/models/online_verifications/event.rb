module OnlineVerifications
  class Event < ApplicationRecord
    belongs_to :verified, class_name: 'User'
  end
end
