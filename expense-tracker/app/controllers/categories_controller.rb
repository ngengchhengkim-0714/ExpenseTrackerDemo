# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @income_categories = current_user.categories.income.order(:name)
    @expense_categories = current_user.categories.expense.order(:name)
    @default_categories = Category.default_categories.order(:category_type, :name)
    @category = Category.new
  end

  def create
    @category = current_user.categories.build(category_params)

    if @category.save
      redirect_to categories_path, notice: 'Category was successfully created.'
    else
      @income_categories = current_user.categories.income.order(:name)
      @expense_categories = current_user.categories.expense.order(:name)
      @default_categories = Category.default_categories.order(:category_type, :name)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: 'Category was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to categories_path, notice: 'Category was successfully deleted.'
    else
      redirect_to categories_path, alert: @category.errors.full_messages.join(', ')
    end
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :category_type, :color, :is_default)
  end
end
