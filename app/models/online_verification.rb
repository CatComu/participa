class OnlineVerification < ApplicationRecord
  enum status: %i(ongoing
                  approved
                  non_local_id_with_missing_proof
                  non_local_id_with_invalid_proof
                  invalid_id
                  unverifiable_id
                  unmatched_identity
                  invalid_other_reason)

  validates :status, presence: true

  belongs_to :verifier, class_name: 'User'
  belongs_to :verified, class_name: 'User'
end
