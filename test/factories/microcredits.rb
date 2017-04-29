# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :microcredit do
    title "Madrid"
    starts_at Time.zone.now
    ends_at Time.zone.now + 1.month
    account_number "XXXXXXXXXX"
    limits "100€: 100\r500€: 22\r1000€: 10"
    total_goal 100000
  end

  trait :expired do
    starts_at Time.zone.now - 6.month
    ends_at Time.zone.now - 2.month
  end
end
