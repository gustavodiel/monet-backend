FactoryBot.define do
  factory :periodic_entry do
    transient do
      year { create(:year) }
    end

    entry_data { attributes_for(:entry).except(:month) }
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
