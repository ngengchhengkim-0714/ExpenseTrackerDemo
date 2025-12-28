# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "Transactions CSV Export", type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user, name: "Groceries") }

  before do
    sign_in user
  end

  describe "GET /transactions.csv" do
    context "with no transactions" do
      it "returns CSV with headers only" do
        get transactions_path(format: :csv)
        
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq("text/csv; charset=utf-8")
        expect(response.headers["Content-Disposition"]).to include("attachment")
        expect(response.headers["Content-Disposition"]).to include("transactions")
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.headers).to eq(["Date", "Description", "Type", "Category", "Amount"])
        expect(csv_data.length).to eq(0)
      end
    end

    context "with transactions" do
      let!(:income) do
        create(:transaction,
               user: user,
               date: Date.new(2025, 1, 15),
               description: "Salary Payment",
               transaction_type: "income",
               category: category,
               amount: 5000.00)
      end
      
      let!(:expense) do
        create(:transaction,
               user: user,
               date: Date.new(2025, 1, 20),
               description: "Grocery Shopping",
               transaction_type: "expense",
               category: category,
               amount: 150.50)
      end

      it "returns success" do
        get transactions_path(format: :csv)
        expect(response).to have_http_status(:success)
      end

      it "sets correct content type" do
        get transactions_path(format: :csv)
        expect(response.content_type).to eq("text/csv; charset=utf-8")
      end

      it "sets content disposition for download" do
        get transactions_path(format: :csv)
        expect(response.headers["Content-Disposition"]).to include("attachment")
        expect(response.headers["Content-Disposition"]).to match(/transactions_\d{8}\.csv/)
      end

      it "includes all transactions" do
        get transactions_path(format: :csv)
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.length).to eq(2)
      end

      it "includes correct headers" do
        get transactions_path(format: :csv)
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.headers).to eq(["Date", "Description", "Type", "Category", "Amount"])
      end

      it "includes transaction data in correct format" do
        get transactions_path(format: :csv)
        
        csv_data = CSV.parse(response.body, headers: true)
        
        # Check income transaction
        income_row = csv_data.find { |row| row["Description"] == "Salary Payment" }
        expect(income_row["Date"]).to eq("2025-01-15")
        expect(income_row["Type"]).to eq("income")
        expect(income_row["Category"]).to eq("Groceries")
        expect(income_row["Amount"]).to eq("5000.00")
        
        # Check expense transaction
        expense_row = csv_data.find { |row| row["Description"] == "Grocery Shopping" }
        expect(expense_row["Date"]).to eq("2025-01-20")
        expect(expense_row["Type"]).to eq("expense")
        expect(expense_row["Category"]).to eq("Groceries")
        expect(expense_row["Amount"]).to eq("150.50")
      end

      it "orders transactions by date descending" do
        get transactions_path(format: :csv)
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data[0]["Description"]).to eq("Grocery Shopping") # Jan 20 (newer)
        expect(csv_data[1]["Description"]).to eq("Salary Payment")   # Jan 15 (older)
      end

      it "handles transactions without categories", :skip => "Requires database migration to allow NULL category_id" do
        uncategorized = create(:transaction,
                               user: user,
                               description: "Misc Expense",
                               transaction_type: "expense",
                               category: nil,
                               amount: 25.00)
        
        get transactions_path(format: :csv)
        
        csv_data = CSV.parse(response.body, headers: true)
        misc_row = csv_data.find { |row| row["Description"] == "Misc Expense" }
        expect(misc_row["Category"]).to eq("Uncategorized")
      end

      it "does not include other users' transactions" do
        other_user = create(:user)
        create(:transaction,
               user: other_user,
               description: "Other User Transaction",
               amount: 999.99)
        
        get transactions_path(format: :csv)
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.length).to eq(2)
        expect(csv_data.map { |r| r["Description"] }).not_to include("Other User Transaction")
      end
    end

    context "with filters" do
      let!(:income) { create(:transaction, user: user, transaction_type: "income", amount: 1000, date: Date.today) }
      let!(:expense) { create(:transaction, user: user, transaction_type: "expense", amount: 500, date: Date.today) }

      it "exports only filtered transactions by type" do
        get transactions_path(format: :csv, transaction_type: "income")
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.length).to eq(1)
        expect(csv_data.first["Type"]).to eq("income")
      end

      it "exports filtered transactions by date range" do
        old_transaction = create(:transaction, user: user, date: Date.today - 60.days, amount: 100)
        
        get transactions_path(format: :csv, 
                             start_date: (Date.today - 7.days).to_s,
                             end_date: Date.today.to_s)
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.length).to eq(2) # Only income and expense from today
      end

      it "exports filtered transactions by category" do
        category2 = create(:category, user: user, name: "Transport")
        create(:transaction, user: user, category: category2, amount: 50, date: Date.today)
        create(:transaction, user: user, category: category, amount: 100, date: Date.today)
        
        get transactions_path(format: :csv, category_id: category.id)
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.length).to eq(1)
        expect(csv_data.first["Category"]).to eq(category.name)
      end
    end

    context "with special characters in data" do
      it "properly escapes commas in descriptions" do
        create(:transaction,
               user: user,
               description: "Grocery, Restaurant, Shopping",
               amount: 100)
        
        get transactions_path(format: :csv)
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.first["Description"]).to eq("Grocery, Restaurant, Shopping")
      end

      it "properly escapes quotes in descriptions" do
        create(:transaction,
               user: user,
               description: 'Payment for "Premium Service"',
               amount: 100)
        
        get transactions_path(format: :csv)
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.first["Description"]).to eq('Payment for "Premium Service"')
      end

      it "properly handles newlines in descriptions" do
        create(:transaction,
               user: user,
               description: "Line 1\nLine 2",
               amount: 100)
        
        get transactions_path(format: :csv)
        
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.first["Description"]).to eq("Line 1\nLine 2")
      end
    end

    context "with large dataset" do
      it "handles 100+ transactions efficiently" do
        create_list(:transaction, 150, user: user)
        
        get transactions_path(format: :csv)
        
        expect(response).to have_http_status(:success)
        csv_data = CSV.parse(response.body, headers: true)
        expect(csv_data.length).to eq(150)
      end
    end
  end

  describe "GET /transactions.csv when not authenticated" do
    before do
      sign_out user
    end

    it "returns unauthorized" do
      get transactions_path(format: :csv)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
