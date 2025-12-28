# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @current_month_start = Date.today.beginning_of_month
    @current_month_end = Date.today.end_of_month
    
    # Current month's transactions
    current_month_transactions = current_user.transactions
                                              .where(date: @current_month_start..@current_month_end)
    
    # Calculate totals
    @total_income = current_month_transactions
                     .where(transaction_type: "income")
                     .sum(:amount)
    
    @total_expenses = current_month_transactions
                       .where(transaction_type: "expense")
                       .sum(:amount)
    
    @balance = @total_income - @total_expenses
    
    # Recent transactions (last 5)
    @recent_transactions = current_user.transactions
                                       .includes(:category)
                                       .order(date: :desc, created_at: :desc)
                                       .limit(5)
    
    # Top spending categories this month
    @top_categories = current_month_transactions
                       .where(transaction_type: "expense")
                       .joins(:category)
                       .group("categories.name")
                       .sum(:amount)
                       .sort_by { |_name, amount| -amount }
                       .first(5)
  end
end
