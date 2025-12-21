# frozen_string_literal: true

module Reports
  class MonthlySummaryService
    attr_reader :user, :start_date, :end_date

    def initialize(user, start_date: nil, end_date: nil)
      @user = user
      @start_date = start_date || Date.today.beginning_of_month
      @end_date = end_date || Date.today.end_of_month
    end

    def call
      {
        total_income: total_income,
        total_expenses: total_expenses,
        net_savings: net_savings,
        savings_rate: savings_rate,
        income_by_category: income_by_category,
        expenses_by_category: expenses_by_category,
        top_expense_categories: top_expense_categories,
        transaction_count: transaction_count,
        average_transaction: average_transaction
      }
    end

    private

    def transactions
      @transactions ||= user.transactions.by_date_range(start_date, end_date)
    end

    def income_transactions
      @income_transactions ||= transactions.income
    end

    def expense_transactions
      @expense_transactions ||= transactions.expense
    end

    def total_income
      @total_income ||= income_transactions.sum(:amount)
    end

    def total_expenses
      @total_expenses ||= expense_transactions.sum(:amount)
    end

    def net_savings
      total_income - total_expenses
    end

    def savings_rate
      return 0 if total_income.zero?
      ((net_savings / total_income) * 100).round(2)
    end

    def income_by_category
      income_transactions
        .joins(:category)
        .group('categories.name')
        .sum(:amount)
        .sort_by { |_, amount| -amount }
    end

    def expenses_by_category
      expense_transactions
        .joins(:category)
        .group('categories.name')
        .sum(:amount)
        .sort_by { |_, amount| -amount }
    end

    def top_expense_categories(limit = 5)
      expenses_by_category.first(limit)
    end

    def transaction_count
      {
        income: income_transactions.count,
        expense: expense_transactions.count,
        total: transactions.count
      }
    end

    def average_transaction
      {
        income: income_transactions.any? ? (total_income / income_transactions.count).round(2) : 0,
        expense: expense_transactions.any? ? (total_expenses / expense_transactions.count).round(2) : 0
      }
    end
  end
end
