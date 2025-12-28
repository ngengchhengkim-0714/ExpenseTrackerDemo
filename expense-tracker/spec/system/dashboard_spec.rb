# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard", type: :system do
  let(:user) { create(:user, email: "test@example.com", password: "Password123!") }

  before do
    driven_by(:selenium_chrome_headless)
  end

  context "when user is logged in" do
    before do
      # Login
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "Password123!"
      click_button "Log in"
    end

    it "displays dashboard overview" do
      expect(page).to have_content("Dashboard")
      expect(page).to have_content("Financial Overview")
    end

    it "shows financial summary cards" do
      expect(page).to have_content("Total Income")
      expect(page).to have_content("Total Expenses")
      expect(page).to have_content("Balance")
    end

    it "shows zero amounts when no transactions exist" do
      within(".income-card") do
        expect(page).to have_content("$0.00")
      end
      
      within(".expenses-card") do
        expect(page).to have_content("$0.00")
      end
      
      within(".balance-card") do
        expect(page).to have_content("$0.00")
      end
    end

    context "with existing transactions" do
      let(:category) { create(:category, user: user, name: "Salary") }
      
      before do
        create(:transaction, 
          user: user, 
          transaction_type: "income", 
          amount: 5000, 
          description: "Monthly Salary",
          category: category,
          date: Date.today
        )
        
        create(:transaction, 
          user: user, 
          transaction_type: "expense", 
          amount: 1200, 
          description: "Rent Payment",
          date: Date.today
        )

        visit dashboard_path
      end

      it "displays correct income total" do
        within(".income-card") do
          expect(page).to have_content("$5,000.00")
        end
      end

      it "displays correct expenses total" do
        within(".expenses-card") do
          expect(page).to have_content("$1,200.00")
        end
      end

      it "calculates balance correctly" do
        within(".balance-card") do
          expect(page).to have_content("$3,800.00")
        end
      end

      it "shows recent transactions list" do
        expect(page).to have_content("Recent Transactions")
        expect(page).to have_content("Monthly Salary")
        expect(page).to have_content("Rent Payment")
      end

      it "shows transaction types with colors" do
        within(".recent-transactions") do
          expect(page).to have_css(".income-badge", text: "Income")
          expect(page).to have_css(".expense-badge", text: "Expense")
        end
      end
    end

    it "provides quick action links" do
      expect(page).to have_link("Add Transaction")
      expect(page).to have_link("View All Transactions")
      expect(page).to have_link("View Reports")
    end

    it "navigates to add transaction page" do
      click_link "Add Transaction"
      expect(page).to have_current_path(new_transaction_path)
      expect(page).to have_content("New Transaction")
    end

    it "navigates to transactions list" do
      click_link "View All Transactions"
      expect(page).to have_current_path(transactions_path)
    end
  end

  context "when user is not logged in" do
    it "redirects to login page" do
      visit dashboard_path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("You need to sign in or sign up before continuing")
    end
  end
end
