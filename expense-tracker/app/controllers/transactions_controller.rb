# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]

  def index
    @transactions = current_user.transactions.includes(:category).recent

    # Apply filters if present
    @transactions = apply_filters(@transactions)

    # Pagination
    @transactions = @transactions.page(params[:page]).per(20)
  end

  def show; end

  def new
    @transaction = current_user.transactions.build(date: Time.zone.today)
    @categories = current_user.categories
  end

  def edit
    @categories = current_user.categories
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)

    if @transaction.save
      redirect_to transactions_path, notice: "Transaction was successfully created."
    else
      @categories = current_user.categories
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_path, notice: "Transaction was successfully updated."
    else
      @categories = current_user.categories
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @transaction.destroy
    redirect_to transactions_path, notice: "Transaction was successfully deleted."
  end

  def summary
    @start_date = params[:start_date]&.to_date || Time.zone.today.beginning_of_month
    @end_date = params[:end_date]&.to_date || Time.zone.today.end_of_month

    transactions = current_user.transactions.by_date_range(@start_date, @end_date)

    @total_income = transactions.income.sum(:amount)
    @total_expenses = transactions.expense.sum(:amount)
    @balance = @total_income - @total_expenses
    @transaction_count = transactions.count

    @income_by_category = transactions.income
                                      .joins(:category)
                                      .group("categories.name")
                                      .sum(:amount)

    @expenses_by_category = transactions.expense
                                        .joins(:category)
                                        .group("categories.name")
                                        .sum(:amount)
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :description, :transaction_type, :date, :category_id)
  end

  def apply_filters(transactions)
    # Filter by transaction type
    transactions = transactions.by_type(params[:type]) if params[:type].present?

    # Filter by category
    transactions = transactions.by_category(params[:category_id]) if params[:category_id].present?

    # Filter by date range
    if params[:start_date].present? && params[:end_date].present?
      transactions = transactions.by_date_range(params[:start_date].to_date, params[:end_date].to_date)
    end

    # Search in description
    transactions = transactions.where("description LIKE ?", "%#{params[:search]}%") if params[:search].present?

    transactions
  end
end
