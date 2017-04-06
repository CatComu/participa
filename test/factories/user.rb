FactoryGirl.define do

  sequence :email do |n|
    "foo#{n}@example.com"
  end

  sequence :document_vatid do |n|
    "#{n.to_s.rjust(8,'0')}#{'TRWAGMYFPDXBNJZSQVHLCKE'[n % 23].chr}"
  end

  sequence :phone do |n|
    "003466111111#{n}"
  end

  factory :user do
    last_name "Perez"
    first_name "Pepito"
    email 
    password '123456789'
    confirmed_at Time.zone.now
    born_at Date.civil(1983, 2, 1) 
    wants_newsletter true
    document_type 1
    document_vatid 
    admin false
    spanish
    address "C/ Inventada, 123" 
    vote_town "m_28_079_6"
    phone
    flags 0
  end

  trait :catalan do
    transient do
      comarca 13
      vegueria "AT01"
    end

    country "ES"
    province "B"
    town "m_08_019_3"
    postal_code "08001"

    catalan_town do
      create(:catalan_town, code: town,
                            comarca_code: comarca,
                            vegueria_code: vegueria)
    end
  end

  trait :spanish do
    country "ES"
    province "M"
    town "m_28_079_6"
    postal_code "28021"
  end

  trait :foreigner do
    country "BR"
    province "RJ"
    town nil
    postal_code "2950-000"
  end

  trait :admin do
    admin true
  end

  trait :superadmin do
    admin

    superadmin true
  end

  trait :not_banned do
    banned false
  end

  trait :banned do
    banned true
  end

  trait :not_confirmed_by_sms do
    sms_confirmed_at nil
  end

  trait :confirmed_by_sms do
    sms_confirmed_at { Time.zone.now }
  end

  trait :pending_moderation do
    confirmed_by_sms

    after(:create) do |u, _|
      u.uploads << create(:online_verification_upload, verified: u)
    end
  end

  trait :pending_docs do
    confirmed_by_sms

    after(:create) do |u, _|
      u.verification_events << create(:online_verification_upload, verified: u, created_at: 1.minute.ago)
      u.verification_events << create(:online_verification_report, verified: u)
    end
  end

  trait :not_verified_presentially do
    verified_by_id nil
  end

  trait :verified_presentially do
    verified_at { Time.zone.now }
    verified_by_id 1
  end

  trait :not_verified_online do
    verified_online_by_id nil
  end

  trait :verified_online do
    confirmed_by_sms

    verified_online_at { Time.zone.now }
    verified_online_by_id 1
  end

  trait :previously_confirmed_by_sms do
    sms_confirmed_at do
      Time.zone.now - User.sms_confirmation_period - 1.day
    end
  end

  trait :newsletter_disabled do
    wants_newsletter false
  end

  trait :newsletter_enabled do
    wants_newsletter true
  end

  trait :foreign do
    document_type 3
    sequence(:document_vatid) { |n| "83482#{n}D" }
  end

  trait :island do
    province "IB"
    postal_code "07021"
    town "m_07_003_3"
  end

  trait :verifying_presentially do
    transient do
      starts_at { 1.day.ago }
      ends_at { 1.day.from_now }
      center nil
    end

    after(:create) do |user, evaluator|
      attrs = {
        user: user,
        starts_at: evaluator.starts_at,
        ends_at: evaluator.ends_at
      }

      attrs[:verification_center] = evaluator.center if evaluator.center

      create(:verification_slot, :presential, attrs)
    end
  end

  trait :verifying_online do
    transient do
      starts_at { 1.day.ago }
      ends_at { 1.day.from_now }
    end

    after(:create) do |user, evaluator|
      create(:verification_slot, :online, user: user,
                                          starts_at: evaluator.starts_at,
                                          ends_at: evaluator.ends_at)
    end
  end
end
