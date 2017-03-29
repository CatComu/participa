module OnlineVerifications
  class Report < Event
    belongs_to :verifier, class_name: 'User'

    has_many :issues
    has_many :labels, through: :issues
  end
end
