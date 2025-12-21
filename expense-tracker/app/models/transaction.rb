# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :description, length: { maximum: 500 }
  validates :transaction_type, presence: true, inclusion: { in: %w[income expense] }
  validates :date, presence: true
  validate :date_not_in_future

  scope :recent, -> { order(date: :desc, created_at: :desc) }
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :income, -> { where(transaction_type: "income") }
  scope :expense, -> { where(transaction_type: "expense") }

  private

  def date_not_in_future
    return unless date.present? && date > Date.today

    errors.add(:date, "cannot be in the future")
  end
end
