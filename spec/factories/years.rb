# frozen_string_literal: true

FactoryBot.define do
  factory :year do
    name { Random.rand(2000..2100) }
    interest_rate { 10.75 }
  end
end
