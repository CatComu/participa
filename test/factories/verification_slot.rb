FactoryGirl.define do
  factory :verification_slot, class: Verification::Slot do
    starts_at { Time.zone.now }
    ends_at { Time.zone.now + 1.day }

    trait :online do
      verification_center nil
    end

    trait :presential do
      verification_center
    end
  end
end
