# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reports::TrendAnalyzerService, type: :service do
  let(:user) { create(:user) }
  let(:income_category) { create(:category, :income, user: user, name: 'Salary') }
  let(:expense_category) { create(:category, :expense, user: user, name: 'Food') }

  before do
    # Create transactions for the last 6 months
    6.times do |i|
      month_date = i.months.ago.beginning_of_month

      # Income increasing over time: oldest month (i=5) has 3000, newest (i=0) has 8000
      create(:transaction, user: user, category: income_category,
             transaction_type: 'income', amount: 3000 + ((5 - i) * 1000), date: month_date)

      # Expenses increasing over time: oldest month (i=5) has 1000, newest (i=0) has 3500
      create(:transaction, user: user, category: expense_category,
             transaction_type: 'expense', amount: 1000 + ((5 - i) * 500), date: month_date)
    end
  end

  subject(:service) { described_class.new(user, months: 6) }
  subject(:trends) { service.call }

  describe '#call' do
    it 'returns a hash with trend data' do
      expect(trends).to be_a(Hash)
      expect(trends).to include(
        :monthly_trends,
        :income_trend,
        :expense_trend,
        :savings_trend,
        :category_trends,
        :averages,
        :growth_rates
      )
    end
  end

  describe '#monthly_trends' do
    it 'returns monthly data for specified number of months' do
      monthly = trends[:monthly_trends]
      expect(monthly.size).to eq(6)
    end

    it 'includes required fields for each month' do
      monthly = trends[:monthly_trends]
      first_month = monthly.first

      expect(first_month).to include(:month, :month_short, :date, :income, :expenses, :net)
    end

    it 'calculates net savings correctly' do
      monthly = trends[:monthly_trends]
      # First month: income 8000, expense 3500, net 4500
      expect(monthly.last[:net]).to eq(monthly.last[:income] - monthly.last[:expenses])
    end

    it 'orders months from oldest to newest' do
      monthly = trends[:monthly_trends]
      dates = monthly.map { |m| m[:date] }
      expect(dates).to eq(dates.sort)
    end
  end

  describe '#income_trend' do
    it 'returns array of month labels and income amounts' do
      income_data = trends[:income_trend]
      expect(income_data).to be_an(Array)
      expect(income_data.first).to be_an(Array)
      expect(income_data.first.size).to eq(2)
    end

    it 'shows increasing income trend' do
      income_data = trends[:income_trend]
      amounts = income_data.map(&:last)
      # Should be increasing: 3000, 4000, 5000, 6000, 7000, 8000
      expect(amounts).to eq(amounts.sort)
    end
  end

  describe '#expense_trend' do
    it 'returns array of month labels and expense amounts' do
      expense_data = trends[:expense_trend]
      expect(expense_data).to be_an(Array)
      expect(expense_data.size).to eq(6)
    end

    it 'shows increasing expense trend' do
      expense_data = trends[:expense_trend]
      amounts = expense_data.map(&:last)
      expect(amounts).to eq(amounts.sort)
    end
  end

  describe '#savings_trend' do
    it 'returns array of month labels and net savings' do
      savings_data = trends[:savings_trend]
      expect(savings_data).to be_an(Array)
      expect(savings_data.size).to eq(6)
    end

    it 'calculates net savings for each month' do
      savings_data = trends[:savings_trend]
      # Check first month
      first_savings = savings_data.first.last
      first_month_data = trends[:monthly_trends].first
      expect(first_savings).to eq(first_month_data[:income] - first_month_data[:expenses])
    end
  end

  describe '#category_trends' do
    it 'returns trend data for top categories' do
      category_data = trends[:category_trends]
      expect(category_data).to be_an(Array)
      expect(category_data).not_to be_empty
    end

    it 'includes category name and data points' do
      category_data = trends[:category_trends]
      first_category = category_data.first

      expect(first_category).to have_key(:name)
      expect(first_category).to have_key(:data)
      expect(first_category[:data]).to be_an(Array)
    end

    it 'limits to top 5 categories' do
      # Create more categories
      10.times do |i|
        category = create(:category, :expense, user: user, name: "Category #{i}")
        create(:transaction, user: user, category: category,
               transaction_type: 'expense', amount: 100, date: 1.month.ago)
      end

      category_data = service.call[:category_trends]
      expect(category_data.size).to be <= 5
    end
  end

  describe '#averages' do
    it 'calculates monthly averages' do
      avgs = trends[:averages]
      expect(avgs).to include(:monthly_income, :monthly_expenses, :monthly_savings)
    end

    it 'returns numeric values' do
      avgs = trends[:averages]
      expect(avgs[:monthly_income]).to be_a(Numeric)
      expect(avgs[:monthly_expenses]).to be_a(Numeric)
      expect(avgs[:monthly_savings]).to be_a(Numeric)
    end

    it 'calculates correct averages' do
      avgs = trends[:averages]
      # Income: 3000, 4000, 5000, 6000, 7000, 8000 = avg 5500
      expect(avgs[:monthly_income]).to eq(5500.0)
      # Expenses: 1000, 1500, 2000, 2500, 3000, 3500 = avg 2250
      expect(avgs[:monthly_expenses]).to eq(2250.0)
    end
  end

  describe '#growth_rates' do
    it 'calculates growth rates for income, expenses, and savings' do
      rates = trends[:growth_rates]
      expect(rates).to include(:income, :expenses, :savings)
    end

    it 'returns percentage values' do
      rates = trends[:growth_rates]
      expect(rates[:income]).to be_a(Numeric)
      expect(rates[:expenses]).to be_a(Numeric)
      expect(rates[:savings]).to be_a(Numeric)
    end

    it 'calculates correct growth rate for income' do
      rates = trends[:growth_rates]
      # From 3000 to 8000 = 166.67% growth
      expect(rates[:income]).to be_within(0.1).of(166.67)
    end

    context 'when start value is zero' do
      let(:empty_user) { create(:user) }
      let(:service) { described_class.new(empty_user, months: 6) }

      it 'returns 0 for all growth rates' do
        rates = service.call[:growth_rates]
        expect(rates[:income]).to eq(0)
        expect(rates[:expenses]).to eq(0)
        expect(rates[:savings]).to eq(0)
      end
    end
  end

  describe 'custom month range' do
    subject(:service) { described_class.new(user, months: 3) }

    it 'analyzes specified number of months' do
      monthly = service.call[:monthly_trends]
      expect(monthly.size).to eq(3)
    end
  end
end
