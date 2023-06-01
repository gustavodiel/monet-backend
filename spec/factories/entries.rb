FactoryBot.define do
  factory :entry do
    name { 'Entry' }
    description { 'This is the description' }
    kind { 'expense' }
    value_cents { 1_000_00 }
    value_currency { 'BRL' }
    payment_method { 'credit_card' }
    category { 'general_expenses' }
    origin { 'Shopping center' }
    installment_number { nil }
    installment_total { nil }
    paid_at { Time.zone.now }
    day_of_month_to_pay { 15 }
    month { create(:year).months.first }

    trait :income do
      kind { 'income' }
    end

    trait :periodic do
      periodic_entry { create(:periodic_entry) }
      installment_number { 1 }
      installment_total { 3 }
    end
  end
end
