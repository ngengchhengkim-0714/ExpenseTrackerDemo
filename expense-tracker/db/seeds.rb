# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Default Categories
puts "Creating default categories..."

default_categories = [
  # Expense Categories
  { name: "Groceries", category_type: "expense", color: "#10B981", is_default: true },
  { name: "Transportation", category_type: "expense", color: "#3B82F6", is_default: true },
  { name: "Utilities", category_type: "expense", color: "#F59E0B", is_default: true },
  { name: "Rent/Mortgage", category_type: "expense", color: "#EF4444", is_default: true },
  { name: "Entertainment", category_type: "expense", color: "#8B5CF6", is_default: true },
  { name: "Healthcare", category_type: "expense", color: "#EC4899", is_default: true },
  { name: "Dining Out", category_type: "expense", color: "#F97316", is_default: true },
  { name: "Shopping", category_type: "expense", color: "#06B6D4", is_default: true },
  { name: "Other Expense", category_type: "expense", color: "#6B7280", is_default: true },

  # Income Categories
  { name: "Salary", category_type: "income", color: "#22C55E", is_default: true },
  { name: "Freelance", category_type: "income", color: "#84CC16", is_default: true },
  { name: "Investment", category_type: "income", color: "#14B8A6", is_default: true },
  { name: "Gift", category_type: "income", color: "#A855F7", is_default: true },
  { name: "Other Income", category_type: "income", color: "#64748B", is_default: true },

  # Uncategorized
  { name: "Uncategorized", category_type: "expense", color: "#9CA3AF", is_default: true }
]

default_categories.each do |category_attrs|
  Category.create!(
    name: category_attrs[:name],
    category_type: category_attrs[:category_type],
    color: category_attrs[:color],
    user_id: nil,
    is_default: true
  ) unless Category.exists?(name: category_attrs[:name], user_id: nil)
end

puts "Created #{Category.default_categories.count} default categories"

# Demo Users and Transactions (only in development)
if Rails.env.development?
  require "faker"

  puts "\nCreating demo users and transactions..."

  NUM_DEMO_USERS = 10
  MIN_TRANSACTIONS = 50
  MAX_TRANSACTIONS = 200
  START_DATE = 6.months.ago.to_date
  END_DATE = Date.today

  NUM_DEMO_USERS.times do |i|
    user = User.find_or_create_by!(email: "demo#{i + 1}@example.com") do |u|
      u.full_name = Faker::Name.name
      u.password = "Password123!"
      u.password_confirmation = "Password123!"
    end

    # Get default categories for this user to use
    expense_categories = Category.default_categories.expense
    income_categories = Category.default_categories.income

    # Generate random number of transactions
    transaction_count = rand(MIN_TRANSACTIONS..MAX_TRANSACTIONS)

    transaction_count.times do
      transaction_type = rand < 0.3 ? "income" : "expense" # 30% income, 70% expense
      categories = transaction_type == "income" ? income_categories : expense_categories

      Transaction.create!(
        user: user,
        category: categories.sample,
        amount: Faker::Commerce.price(range: 5.0..500.0),
        description: transaction_type == "income" ? Faker::Company.bs : Faker::Commerce.product_name,
        transaction_type: transaction_type,
        date: Faker::Date.between(from: START_DATE, to: END_DATE)
      )
    end

    puts "Created user: #{user.email} with #{transaction_count} transactions"
  end

  puts "\nDemo data created successfully!"
  puts "Login with any of these accounts:"
  puts "  Email: demo1@example.com to demo#{NUM_DEMO_USERS}@example.com"
  puts "  Password: Password123!"
end
