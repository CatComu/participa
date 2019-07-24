# frozen_string_literal: true

FactoryGirl.define do
  factory :vegueria do
    code Faker::Address.country_code_long
    name Faker::Address.state
  end
end
