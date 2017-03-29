module OnlineVerifications
  class Issue < ApplicationRecord
    belongs_to :report
    belongs_to :label

    validates :report, :label, presence: true
  end
end
