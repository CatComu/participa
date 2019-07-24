# frozen_string_literal: true

FactoryGirl.define do
  factory :position do
    name Faker::Job.position
    association :group
    position_type Random.rand(0..2)

    trait :downloader do
      downloader true
    end
  end
end
