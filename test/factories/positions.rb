# frozen_string_literal: true

FactoryGirl.define do
  factory :position do
    name Faker::Job.position
    association :group
    position_type Random.rand(0..3)
  end
end
