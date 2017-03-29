FactoryGirl.define do
  factory :online_verification_label, class: OnlineVerifications::Label do
    code 'invalid_id'
  end

  factory :online_verification_report, class: OnlineVerifications::Report do
    association :verified, factory: [:user, :confirmed_by_sms]
    association :verifier, factory: [:user, :verifying_online]
  end
end
