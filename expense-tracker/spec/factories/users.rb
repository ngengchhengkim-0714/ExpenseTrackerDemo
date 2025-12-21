# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    full_name { Faker::Name.name }
    password { 'Password123!' }
    password_confirmation { 'Password123!' }

    trait :with_transactions do
      after(:create) do |user|
        create_list(:transaction, 10, user: user)
      end
    end

    trait :with_categories do
      after(:create) do |user|
        create_list(:category, 5, user: user)
      end
    end

    trait :with_full_data do
      after(:create) do |user|
        categories = create_list(:category, 5, user: user)
        create_list(:transaction, 20, user: user, category: categories.sample)
      end
    end
  end
end
