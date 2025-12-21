# frozen_string_literal: true

class Category < ApplicationRecord
  belongs_to :user, optional: true
  has_many :transactions, dependent: :restrict_with_error

  validates :name, presence: true
  validates :category_type, presence: true, inclusion: { in: %w[income expense] }
  validates :name, uniqueness: { scope: :user_id }
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i }, allow_blank: true

  scope :default_categories, -> { where(is_default: true, user_id: nil) }
  scope :user_categories, ->(user) { where(user: user) }
  scope :income, -> { where(category_type: "income") }
  scope :expense, -> { where(category_type: "expense") }
end
