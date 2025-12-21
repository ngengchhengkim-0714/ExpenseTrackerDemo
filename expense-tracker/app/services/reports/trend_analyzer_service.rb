# frozen_string_literal: true

module Reports
  class TrendAnalyzerService
    attr_reader :user, :months

    def initialize(user, months: 6)
      @user = user
      @months = months
    end

    def call
      {
        monthly_trends: monthly_trends,
        income_trend: income_trend,
        expense_trend: expense_trend,
        savings_trend: savings_trend,
        category_trends: category_trends,
        averages: averages,
        growth_rates: growth_rates
      }
    end

    private

    def monthly_trends
      @monthly_trends ||= (0...months).map do |i|
        month_start = i.months.ago.beginning_of_month
        month_end = i.months.ago.end_of_month

        transactions = user.transactions.by_date_range(month_start, month_end)
        income = transactions.income.sum(:amount)
        expenses = transactions.expense.sum(:amount)

        {
          month: month_start.strftime('%B %Y'),
          month_short: month_start.strftime('%b %y'),
          date: month_start,
          income: income,
          expenses: expenses,
          net: income - expenses
        }
      end.reverse
    end

    def income_trend
      monthly_trends.map { |m| [m[:month_short], m[:income]] }
    end

    def expense_trend
      monthly_trends.map { |m| [m[:month_short], m[:expenses]] }
    end

    def savings_trend
      monthly_trends.map { |m| [m[:month_short], m[:net]] }
    end

    def category_trends
      top_categories = user.transactions
        .joins(:category)
        .where('date >= ?', months.months.ago)
        .group('categories.name')
        .sum(:amount)
        .sort_by { |_, amount| -amount }
        .first(5)
        .map(&:first)

      top_categories.map do |category_name|
        trend_data = (0...months).map do |i|
          month_start = i.months.ago.beginning_of_month
          month_end = i.months.ago.end_of_month

          amount = user.transactions
            .joins(:category)
            .where(categories: { name: category_name })
            .by_date_range(month_start, month_end)
            .sum(:amount)

          [month_start.strftime('%b %y'), amount]
        end.reverse

        {
          name: category_name,
          data: trend_data
        }
      end
    end

    def averages
      income_values = monthly_trends.map { |m| m[:income] }
      expense_values = monthly_trends.map { |m| m[:expenses] }

      {
        monthly_income: calculate_average(income_values),
        monthly_expenses: calculate_average(expense_values),
        monthly_savings: calculate_average(monthly_trends.map { |m| m[:net] })
      }
    end

    def growth_rates
      return {} if monthly_trends.size < 2

      first_month = monthly_trends.first
      last_month = monthly_trends.last

      {
        income: calculate_growth_rate(first_month[:income], last_month[:income]),
        expenses: calculate_growth_rate(first_month[:expenses], last_month[:expenses]),
        savings: calculate_growth_rate(first_month[:net], last_month[:net])
      }
    end

    def calculate_average(values)
      return 0 if values.empty?
      (values.sum / values.size.to_f).round(2)
    end

    def calculate_growth_rate(start_value, end_value)
      return 0 if start_value.zero?
      (((end_value - start_value) / start_value.to_f) * 100).round(2)
    end
  end
end
