# frozen_string_literal: true

FactoryGirl.define do
  factory :group do
    name Faker::Company.industry
    starts_at Date.today
    ends_at Date.today + 1.year
    is_institutional false
    has_location true
    association :territory, factory: :vegueria
    territory_type "Vegueria"
    location_type "vegueria"
    description nil
  end
end
