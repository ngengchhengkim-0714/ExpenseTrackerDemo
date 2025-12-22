# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    category_type { %w[income expense].sample }
    color { Faker::Color.hex_color }
    is_default { false }
    user

    trait :income do
      category_type { "income" }
    end

    trait :expense do
      category_type { "expense" }
    end

    trait :default do
      is_default { true }
      user { nil }
    end

    trait :with_transactions do
      after(:create) do |category|
        create_list(:transaction, 5, category: category, transaction_type: category.category_type)
      end
    end
  end
end
