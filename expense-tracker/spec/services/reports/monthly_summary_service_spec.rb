# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::MonthlySummaryService, type: :service do
  let(:user) { create(:user) }
  let(:income_category) { create(:category, :income, user: user, name: "Salary") }
  let(:expense_category1) { create(:category, :expense, user: user, name: "Food") }
  let(:expense_category2) { create(:category, :expense, user: user, name: "Transport") }

  let(:start_date) { Date.new(2025, 1, 1) }
  let(:end_date) { Date.new(2025, 1, 31) }

  before do
    # Income transactions
    create(:transaction, user: user, category: income_category,
                         transaction_type: "income", amount: 5000, date: Date.new(2025, 1, 1))
    create(:transaction, user: user, category: income_category,
                         transaction_type: "income", amount: 3000, date: Date.new(2025, 1, 15))

    # Expense transactions
    create(:transaction, user: user, category: expense_category1,
                         transaction_type: "expense", amount: 1500, date: Date.new(2025, 1, 5))
    create(:transaction, user: user, category: expense_category1,
                         transaction_type: "expense", amount: 1000, date: Date.new(2025, 1, 20))
    create(:transaction, user: user, category: expense_category2,
                         transaction_type: "expense", amount: 500, date: Date.new(2025, 1, 10))

    # Transaction outside date range (should be excluded)
    create(:transaction, user: user, category: expense_category1,
                         transaction_type: "expense", amount: 2000, date: Date.new(2025, 2, 1))
  end

  subject(:service) { described_class.new(user, start_date: start_date, end_date: end_date) }
  subject(:summary) { service.call }

  describe "#call" do
    it "returns a hash with summary data" do
      expect(summary).to be_a(Hash)
      expect(summary).to include(
        :total_income,
        :total_expenses,
        :net_savings,
        :savings_rate,
        :income_by_category,
        :expenses_by_category,
        :top_expense_categories,
        :transaction_count,
        :average_transaction
      )
    end
  end

  describe "#total_income" do
    it "calculates total income for the period" do
      expect(summary[:total_income]).to eq(8000)
    end
  end

  describe "#total_expenses" do
    it "calculates total expenses for the period" do
      expect(summary[:total_expenses]).to eq(3000)
    end
  end

  describe "#net_savings" do
    it "calculates net savings (income - expenses)" do
      expect(summary[:net_savings]).to eq(5000)
    end
  end

  describe "#savings_rate" do
    it "calculates savings rate as percentage" do
      expect(summary[:savings_rate]).to eq(62.5)
    end

    context "when no income" do
      before do
        user.transactions.income.destroy_all
      end

      it "returns 0" do
        expect(service.call[:savings_rate]).to eq(0)
      end
    end
  end

  describe "#income_by_category" do
    it "groups income by category with totals" do
      income_by_cat = summary[:income_by_category]
      expect(income_by_cat).to be_an(Array)
      expect(income_by_cat.first).to eq(["Salary", 8000])
    end

    it "sorts categories by amount descending" do
      # Add another income category
      other_income_category = create(:category, :income, user: user, name: "Bonus")
      create(:transaction, user: user, category: other_income_category,
                           transaction_type: "income", amount: 1000, date: Date.new(2025, 1, 25))

      income_by_cat = service.call[:income_by_category]
      expect(income_by_cat.map(&:first)).to eq(%w[Salary Bonus])
      expect(income_by_cat.map(&:last)).to eq([8000, 1000])
    end
  end

  describe "#expenses_by_category" do
    it "groups expenses by category with totals" do
      expenses_by_cat = summary[:expenses_by_category]
      expect(expenses_by_cat).to be_an(Array)
      expect(expenses_by_cat.map(&:first)).to match_array(%w[Food Transport])
      expect(expenses_by_cat.find { |name, _| name == "Food" }.last).to eq(2500)
      expect(expenses_by_cat.find { |name, _| name == "Transport" }.last).to eq(500)
    end

    it "sorts categories by amount descending" do
      expenses_by_cat = summary[:expenses_by_category]
      expect(expenses_by_cat.first).to eq(["Food", 2500])
      expect(expenses_by_cat.last).to eq(["Transport", 500])
    end
  end

  describe "#top_expense_categories" do
    it "returns top 5 expense categories by default" do
      top_categories = summary[:top_expense_categories]
      expect(top_categories.size).to be <= 5
      expect(top_categories.first).to eq(["Food", 2500])
    end

    it "limits results to specified number" do
      # Create more categories
      6.times do |i|
        category = create(:category, :expense, user: user, name: "Category #{i}")
        create(:transaction, user: user, category: category,
                             transaction_type: "expense", amount: 100, date: Date.new(2025, 1, i + 1))
      end

      service = described_class.new(user, start_date: start_date, end_date: end_date)
      top_3 = service.send(:top_expense_categories, 3)
      expect(top_3.size).to eq(3)
    end
  end

  describe "#transaction_count" do
    it "counts transactions by type" do
      counts = summary[:transaction_count]
      expect(counts[:income]).to eq(2)
      expect(counts[:expense]).to eq(3)
      expect(counts[:total]).to eq(5)
    end
  end

  describe "#average_transaction" do
    it "calculates average transaction amounts" do
      averages = summary[:average_transaction]
      expect(averages[:income]).to eq(4000.0)
      expect(averages[:expense]).to eq(1000.0)
    end

    context "when no transactions" do
      let(:empty_user) { create(:user) }
      let(:service) { described_class.new(empty_user, start_date: start_date, end_date: end_date) }

      it "returns 0 for both" do
        averages = service.call[:average_transaction]
        expect(averages[:income]).to eq(0)
        expect(averages[:expense]).to eq(0)
      end
    end
  end

  describe "default date range" do
    subject(:service) { described_class.new(user) }

    it "defaults to current month" do
      expect(service.start_date).to eq(Time.zone.today.beginning_of_month)
      expect(service.end_date).to eq(Time.zone.today.end_of_month)
    end
  end
end
