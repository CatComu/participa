# frozen_string_literal: true

FactoryGirl.define do
  factory :group do
    name Faker::Company.industry
    starts_at Date.today
    ends_at Date.today + 1.year
    is_institutional false
    has_location false
    location_type nil
    has_space false
    space_type nil
  end
end
