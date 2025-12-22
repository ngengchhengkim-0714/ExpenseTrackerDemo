# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Transaction Management", type: :system do
  before do
    driven_by(:selenium_headless)
  end

  let(:user) { create(:user, password: "Password123!", full_name: "Test User") }
  let(:category_expense) { create(:category, user: user, name: "Groceries", category_type: "expense") }
  let(:category_income) { create(:category, user: user, name: "Salary", category_type: "income") }

  before do
    sign_in user
  end

  describe "Creating a transaction" do
    it "allows user to create an expense transaction" do
      visit transactions_path
      click_link "New Transaction"

      fill_in "Amount", with: "50.75"
      fill_in "Description", with: "Weekly groceries"
      select "Groceries", from: "Category"
      select "expense", from: "Type"
      fill_in "Date", with: Time.zone.today.to_s

      click_button "Create Transaction"

      expect(page).to have_content("Transaction was successfully created")
      expect(page).to have_content("Weekly groceries")
      expect(page).to have_content("50.75")
    end

    it "allows user to create an income transaction" do
      visit new_transaction_path

      fill_in "Amount", with: "2000.00"
      fill_in "Description", with: "Monthly salary"
      select "Salary", from: "Category"
      select "income", from: "Type"
      fill_in "Date", with: Time.zone.today.to_s

      click_button "Create Transaction"

      expect(page).to have_content("Transaction was successfully created")
      expect(page).to have_content("Monthly salary")
      expect(page).to have_content("2000")
    end

    it "shows validation errors for invalid data" do
      visit new_transaction_path

      fill_in "Amount", with: "-10"
      click_button "Create Transaction"

      expect(page).to have_content("error")
      expect(page).to have_content("Amount must be greater than 0")
    end

    it "prevents future dates" do
      visit new_transaction_path

      fill_in "Amount", with: "50"
      fill_in "Date", with: 1.day.from_now.to_date.to_s
      click_button "Create Transaction"

      expect(page).to have_content("Date cannot be in the future")
    end
  end

  describe "Viewing transactions" do
    let!(:expense) { create(:transaction, user: user, category: category_expense, description: "Coffee shop", amount: 5.50, transaction_type: "expense", date: Time.zone.today) }
    let!(:income) { create(:transaction, user: user, category: category_income, description: "Freelance work", amount: 500.00, transaction_type: "income", date: 1.day.ago) }

    it "displays all user transactions" do
      visit transactions_path

      expect(page).to have_content("Coffee shop")
      expect(page).to have_content("5.50")
      expect(page).to have_content("Freelance work")
      expect(page).to have_content("500")
    end

    it "shows transaction details" do
      visit transactions_path
      click_link "Coffee shop"

      expect(page).to have_content("Coffee shop")
      expect(page).to have_content("5.50")
      expect(page).to have_content("Groceries")
      expect(page).to have_content("expense")
    end

    it "filters transactions by type" do
      visit transactions_path

      select "expense", from: "Type filter"
      click_button "Filter"

      expect(page).to have_content("Coffee shop")
      expect(page).not_to have_content("Freelance work")
    end

    it "filters transactions by category" do
      visit transactions_path

      select "Groceries", from: "Category filter"
      click_button "Filter"

      expect(page).to have_content("Coffee shop")
      expect(page).not_to have_content("Freelance work")
    end
  end

  describe "Editing a transaction" do
    let!(:transaction) { create(:transaction, user: user, category: category_expense, description: "Original description", amount: 100) }

    it "allows user to edit transaction" do
      visit transactions_path
      click_link "Edit", match: :first

      fill_in "Amount", with: "150.00"
      fill_in "Description", with: "Updated description"
      click_button "Update Transaction"

      expect(page).to have_content("Transaction was successfully updated")
      expect(page).to have_content("Updated description")
      expect(page).to have_content("150")
    end

    it "shows validation errors when editing with invalid data" do
      visit edit_transaction_path(transaction)

      fill_in "Amount", with: "0"
      click_button "Update Transaction"

      expect(page).to have_content("error")
      expect(page).to have_content("Amount must be greater than 0")
    end
  end

  describe "Deleting a transaction" do
    let!(:transaction) { create(:transaction, user: user, category: category_expense, description: "To be deleted") }

    it "allows user to delete transaction", js: true do
      visit transactions_path

      expect(page).to have_content("To be deleted")

      accept_confirm do
        click_link "Delete", match: :first
      end

      expect(page).to have_content("Transaction was successfully deleted")
      expect(page).not_to have_content("To be deleted")
    end
  end

  describe "Transaction summary" do
    let!(:incomes) { create_list(:transaction, 3, :income, user: user, amount: 1000) }
    let!(:expenses) { create_list(:transaction, 5, :expense, user: user, amount: 200) }

    it "displays summary statistics" do
      visit transactions_path
      click_link "Summary"

      expect(page).to have_content("Total Income")
      expect(page).to have_content("3000") # 3 x 1000
      expect(page).to have_content("Total Expenses")
      expect(page).to have_content("1000") # 5 x 200
      expect(page).to have_content("Balance")
      expect(page).to have_content("2000") # 3000 - 1000
    end
  end

  describe "Date range filtering" do
    let!(:old_transaction) { create(:transaction, user: user, date: 30.days.ago, description: "Old transaction") }
    let!(:recent_transaction) { create(:transaction, user: user, date: Time.zone.today, description: "Recent transaction") }

    it "filters transactions by date range" do
      visit transactions_path

      fill_in "Start date", with: 7.days.ago.to_date.to_s
      fill_in "End date", with: Time.zone.today.to_s
      click_button "Filter"

      expect(page).to have_content("Recent transaction")
      expect(page).not_to have_content("Old transaction")
    end
  end

  describe "Sorting transactions" do
    let!(:transaction1) { create(:transaction, user: user, description: "First", date: 3.days.ago, amount: 50) }
    let!(:transaction2) { create(:transaction, user: user, description: "Second", date: 1.day.ago, amount: 100) }
    let!(:transaction3) { create(:transaction, user: user, description: "Third", date: 2.days.ago, amount: 75) }

    it "sorts transactions by date (newest first by default)" do
      visit transactions_path

      transactions_text = page.text
      expect(transactions_text.index("Second")).to be < transactions_text.index("Third")
      expect(transactions_text.index("Third")).to be < transactions_text.index("First")
    end

    it "sorts transactions by amount" do
      visit transactions_path

      select "Amount", from: "Sort by"
      click_button "Sort"

      page.text
      # Should sort by amount ascending or descending
      expect(page).to have_content("50")
      expect(page).to have_content("75")
      expect(page).to have_content("100")
    end
  end
end
