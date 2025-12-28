# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /dashboard" do
    context "with no transactions" do
      it "returns success" do
        get dashboard_path
        expect(response).to have_http_status(:success)
      end

      it "shows zero balances" do
        get dashboard_path
        expect(response.body).to include("$0.00")
      end
    end

    context "with transactions" do
      let!(:income1) { create(:transaction, user: user, transaction_type: "income", amount: 5000, date: Date.today) }
      let!(:income2) { create(:transaction, user: user, transaction_type: "income", amount: 1500, date: Date.today - 5.days) }
      let!(:expense1) { create(:transaction, user: user, transaction_type: "expense", amount: 1200, date: Date.today) }
      let!(:expense2) { create(:transaction, user: user, transaction_type: "expense", amount: 800, date: Date.today - 3.days) }
      let!(:old_transaction) { create(:transaction, user: user, transaction_type: "income", amount: 1000, date: Date.today - 60.days) }

      it "returns success" do
        get dashboard_path
        expect(response).to have_http_status(:success)
      end

      it "displays current month's total income" do
        get dashboard_path
        expect(response.body).to include("$6,500.00") # 5000 + 1500
      end

      it "displays current month's total expenses" do
        get dashboard_path
        expect(response.body).to include("$2,000.00") # 1200 + 800
      end

      it "displays current month's balance" do
        get dashboard_path
        expect(response.body).to include("$4,500.00") # 6500 - 2000
      end

      it "shows recent transactions" do
        get dashboard_path
        expect(response.body).to include(income1.description)
        expect(response.body).to include(expense1.description)
      end

      it "limits recent transactions to 5" do
        6.times { |i| create(:transaction, user: user, description: "Transaction #{i}", date: Date.today - i.days) }
        get dashboard_path
        
        # Check that we have transaction items in the response
        transaction_count = response.body.scan(/transaction-item/).size
        expect(transaction_count).to be <= 5
      end

      it "does not show other users' data" do
        other_user = create(:user)
        other_transaction = create(:transaction, user: other_user, description: "Other user transaction")

        get dashboard_path
        expect(response.body).not_to include(other_transaction.description)
      end
    end

    context "with transactions spanning multiple months" do
      let!(:current_income) { create(:transaction, user: user, transaction_type: "income", amount: 3000, date: Date.today) }
      let!(:last_month_income) { create(:transaction, user: user, transaction_type: "income", amount: 2000, date: Date.today - 1.month) }

      it "only includes current month's transactions in totals" do
        get dashboard_path
        expect(response.body).to include("$3,000.00")
        expect(response.body).not_to include("$5,000.00")
      end
    end

    context "with category breakdown" do
      let(:category1) { create(:category, user: user, name: "Groceries") }
      let(:category2) { create(:category, user: user, name: "Transport") }
      
      let!(:expense1) { create(:transaction, user: user, category: category1, transaction_type: "expense", amount: 500, date: Date.today) }
      let!(:expense2) { create(:transaction, user: user, category: category2, transaction_type: "expense", amount: 300, date: Date.today) }

      it "displays category names" do
        get dashboard_path
        expect(response.body).to include("Groceries")
        expect(response.body).to include("Transport")
      end
    end
  end

  describe "GET /dashboard when not authenticated" do
    before do
      sign_out user
    end

    it "redirects to login" do
      get dashboard_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
