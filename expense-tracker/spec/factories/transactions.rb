# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    user
    category
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    description { Faker::Lorem.sentence(word_count: 5) }
    transaction_type { %w[income expense].sample }
    date { Faker::Date.between(from: 6.months.ago, to: Time.zone.today) }

    trait :income do
      transaction_type { "income" }
      association :category, factory: :category, category_type: "income"
    end

    trait :expense do
      transaction_type { "expense" }
      association :category, factory: :category, category_type: "expense"
    end

    trait :recent do
      date { Time.zone.today }
    end

    trait :last_month do
      date { 1.month.ago }
    end

    trait :large_amount do
      amount { Faker::Number.between(from: 1000, to: 10_000) }
    end

    trait :small_amount do
      amount { Faker::Number.between(from: 1, to: 50) }
    end
  end
end
