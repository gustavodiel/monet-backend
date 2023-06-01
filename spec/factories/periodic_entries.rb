# frozen_string_literal: true

FactoryBot.define do
  factory :periodic_entry do
    transient do
      year { create(:year) }
    end

    entry_data do
      {
        name: 'Entry',
        description: 'This is the description',
        kind: 'expense',
        value_cents: 100_000,
        value_currency: 'BRL',
        payment_method: 'credit_card',
        category: 'general_expenses',
        origin: 'Shopping center',
        installment_number: nil,
        installment_total: nil,
        day_of_month_to_pay: 15
      }
    end

    start_month_id { nil }
    end_month_id { nil }
    interval { :monthly }
    fulfilled { false }

    after(:build) do |periodic_entry, evaluator|
      periodic_entry.start_month ||= evaluator.year.months.first
      periodic_entry.end_month ||= evaluator.year.months.last
    end

    trait :yearly do
      interval { :yearly }
    end
  end
end
