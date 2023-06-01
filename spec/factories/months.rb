# frozen_string_literal: true

FactoryBot.define do
  factory :month do
    name { 1 }
    total_cents { nil }
    total_currency { 'BRL' }
    year { create(:year) }
  end
end
