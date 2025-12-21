# Data Model: Personal Finance Tracker

**Date**: 2025-12-21
**Feature**: Personal Finance Tracker
**Branch**: 001-expense-tracker

## Overview

This document defines the database schema, entities, relationships, and validation rules for the expense tracker application.

## Entity Relationship Diagram

```
┌─────────────────┐
│      User       │
├─────────────────┤
│ id              │◄────────┐
│ email           │         │
│ encrypted_pwd   │         │ user_id (FK)
│ full_name       │         │
│ created_at      │    ┌────┴──────────────┐
│ updated_at      │    │   Transaction     │
└─────────────────┘    ├───────────────────┤
                       │ id                │
┌─────────────────┐    │ user_id          ├───┐
│    Category     │    │ category_id       │   │
├─────────────────┤    │ amount            │   │
│ id              │◄───┤ description       │   │
│ name            │    │ transaction_type  │   │
│ color           │    │ date              │   │
│ category_type   │    │ created_at        │   │
│ is_default      │    │ updated_at        │   │
│ user_id         │    └───────────────────┘   │
│ created_at      │                            │
│ updated_at      │                            │
└─────────────────┘                            │
         ▲                                     │
         └─────────────────────────────────────┘
                   category_id (FK)
```

## Entities

### 1. User

Represents a registered user account with authentication credentials.

**Table**: `users`

**Fields**:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| email | VARCHAR(255) | UNIQUE, NOT NULL | Login email address |
| encrypted_password | VARCHAR(255) | NOT NULL | BCrypt hashed password |
| full_name | VARCHAR(255) | NOT NULL | User's display name |
| reset_password_token | VARCHAR(255) | UNIQUE, NULL | Token for password reset |
| reset_password_sent_at | DATETIME | NULL | Password reset request timestamp |
| remember_created_at | DATETIME | NULL | Remember me token timestamp |
| sign_in_count | INT | DEFAULT 0 | Number of successful logins |
| current_sign_in_at | DATETIME | NULL | Current login timestamp |
| last_sign_in_at | DATETIME | NULL | Previous login timestamp |
| current_sign_in_ip | VARCHAR(255) | NULL | Current login IP address |
| last_sign_in_ip | VARCHAR(255) | NULL | Previous login IP address |
| created_at | DATETIME | NOT NULL | Account creation timestamp |
| updated_at | DATETIME | NOT NULL | Last update timestamp |

**Indexes**:
- `index_users_on_email` (UNIQUE)
- `index_users_on_reset_password_token` (UNIQUE)

**Validations** (Rails Model):
```ruby
validates :email, presence: true, uniqueness: { case_insensitive: true },
          format: { with: URI::MailTo::EMAIL_REGEXP }
validates :full_name, presence: true, length: { minimum: 2, maximum: 255 }
validates :password, presence: true, length: { minimum: 8 },
          format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/,
                    message: "must include uppercase, lowercase, number, and special character" },
          if: :password_required?
```

**Associations**:
- `has_many :transactions, dependent: :destroy`
- `has_many :categories, dependent: :destroy`

**Business Rules**:
- Email must be unique (case-insensitive)
- Password must meet complexity requirements
- Session expires after 30 minutes of inactivity
- Account can be soft-deleted (keep financial history)

---

### 2. Category

Represents a classification for transactions (e.g., Groceries, Salary).

**Table**: `categories`

**Fields**:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| name | VARCHAR(100) | NOT NULL | Category name |
| color | VARCHAR(7) | NULL | Hex color code (e.g., #FF5733) |
| category_type | ENUM | NOT NULL | 'income', 'expense', 'both' |
| is_default | BOOLEAN | DEFAULT FALSE | System-provided category |
| user_id | BIGINT | NULL, FOREIGN KEY | NULL for defaults, user ID for custom |
| created_at | DATETIME | NOT NULL | Creation timestamp |
| updated_at | DATETIME | NOT NULL | Last update timestamp |

**Indexes**:
- `index_categories_on_user_id`
- `index_categories_on_name_and_user_id` (UNIQUE for custom categories)

**Validations** (Rails Model):
```ruby
validates :name, presence: true, length: { maximum: 100 }
validates :name, uniqueness: { scope: :user_id }, unless: :is_default?
validates :category_type, presence: true,
          inclusion: { in: %w[income expense both] }
validates :color, format: { with: /\A#[0-9A-F]{6}\z/i },
          allow_nil: true
validate :default_categories_cannot_have_user
```

**Associations**:
- `belongs_to :user, optional: true` (NULL for system defaults)
- `has_many :transactions, dependent: :restrict_with_error`

**Business Rules**:
- Default categories (`is_default: true`) have `user_id: NULL`
- User can only see default categories + their own custom categories
- Cannot delete category with associated transactions (use soft delete or reassign)
- Category name must be unique per user (case-insensitive)

**Default Categories**:
```ruby
# Expense Categories
- "Groceries" (color: #4CAF50)
- "Transportation" (color: #2196F3)
- "Utilities" (color: #FFC107)
- "Rent/Mortgage" (color: #9C27B0)
- "Entertainment" (color: #E91E63)
- "Healthcare" (color: #00BCD4)
- "Dining Out" (color: #FF5722)
- "Shopping" (color: #795548)
- "Other Expense" (color: #607D8B)

# Income Categories
- "Salary" (color: #8BC34A)
- "Freelance" (color: #CDDC39)
- "Investment" (color: #009688)
- "Gift" (color: #FF9800)
- "Other Income" (color: #03A9F4)

# Special Category
- "Uncategorized" (color: #9E9E9E, type: 'both')
```

---

### 3. Transaction

Represents a single financial entry (income or expense).

**Table**: `transactions`

**Fields**:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| user_id | BIGINT | NOT NULL, FOREIGN KEY | Owner of transaction |
| category_id | BIGINT | NOT NULL, FOREIGN KEY | Assigned category |
| amount | DECIMAL(10,2) | NOT NULL | Transaction amount (positive) |
| description | VARCHAR(500) | NULL | Optional description |
| transaction_type | ENUM | NOT NULL | 'income' or 'expense' |
| date | DATE | NOT NULL | Transaction date |
| created_at | DATETIME | NOT NULL | Record creation timestamp |
| updated_at | DATETIME | NOT NULL | Last update timestamp |

**Indexes**:
- `index_transactions_on_user_id`
- `index_transactions_on_category_id`
- `index_transactions_on_user_id_and_date` (composite for dashboard queries)
- `index_transactions_on_date`

**Validations** (Rails Model):
```ruby
validates :amount, presence: true, numericality: {
  greater_than: 0,
  less_than_or_equal_to: 999999.99
}
validates :transaction_type, presence: true,
          inclusion: { in: %w[income expense] }
validates :date, presence: true
validate :date_not_too_far_in_future
validate :category_matches_transaction_type

def date_not_too_far_in_future
  if date.present? && date > 7.days.from_now.to_date
    errors.add(:date, "cannot be more than 7 days in the future")
  end
end

def category_matches_transaction_type
  return unless category && transaction_type
  if category.category_type != 'both' && category.category_type != transaction_type
    errors.add(:category, "type doesn't match transaction type")
  end
end
```

**Associations**:
- `belongs_to :user`
- `belongs_to :category`

**Scopes**:
```ruby
scope :income, -> { where(transaction_type: 'income') }
scope :expense, -> { where(transaction_type: 'expense') }
scope :for_month, ->(year, month) {
  where(date: Date.new(year, month, 1)..Date.new(year, month, -1))
}
scope :recent, -> { order(date: :desc, created_at: :desc) }
scope :by_category, ->(category_id) { where(category_id: category_id) }
```

**Business Rules**:
- Amount must be positive (sign determined by `transaction_type`)
- Date cannot be more than 7 days in the future
- Description is optional but recommended
- Category type must match transaction type (or be 'both')
- Soft delete recommended (preserve financial history)

---

## Computed Views/Aggregations

### Monthly Summary (Not a table, computed on-demand)

**Purpose**: Aggregate transactions for a specific user and month.

**Computed Fields**:
```ruby
class MonthlySummary
  attr_reader :year, :month, :user

  def total_income
    transactions.income.sum(:amount)
  end

  def total_expense
    transactions.expense.sum(:amount)
  end

  def net_savings
    total_income - total_expense
  end

  def category_breakdown
    transactions.group(:category)
               .select('categories.name, categories.color,
                        SUM(amount) as total,
                        COUNT(*) as count')
               .joins(:category)
  end

  def transactions
    Transaction.where(user: user)
               .for_month(year, month)
  end
end
```

---

## Database Migrations

### Migration 1: Create Users (Devise)

```ruby
class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :full_name,          null: false

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
```

### Migration 2: Create Categories

```ruby
class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false, limit: 100
      t.string :color, limit: 7
      t.string :category_type, null: false, limit: 10
      t.boolean :is_default, default: false, null: false
      t.references :user, foreign_key: true, null: true

      t.timestamps
    end

    add_index :categories, [:name, :user_id], unique: true,
              where: "user_id IS NOT NULL"
  end
end
```

### Migration 3: Create Transactions

```ruby
class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :description, limit: 500
      t.string :transaction_type, null: false, limit: 10
      t.date :date, null: false

      t.timestamps
    end

    add_index :transactions, [:user_id, :date]
    add_index :transactions, :date
  end
end
```

### Migration 4: Seed Default Categories

```ruby
class SeedDefaultCategories < ActiveRecord::Migration[7.1]
  def up
    default_categories = [
      # Expense categories
      { name: "Groceries", color: "#4CAF50", category_type: "expense" },
      { name: "Transportation", color: "#2196F3", category_type: "expense" },
      { name: "Utilities", color: "#FFC107", category_type: "expense" },
      { name: "Rent/Mortgage", color: "#9C27B0", category_type: "expense" },
      { name: "Entertainment", color: "#E91E63", category_type: "expense" },
      { name: "Healthcare", color: "#00BCD4", category_type: "expense" },
      { name: "Dining Out", color: "#FF5722", category_type: "expense" },
      { name: "Shopping", color: "#795548", category_type: "expense" },
      { name: "Other Expense", color: "#607D8B", category_type: "expense" },
      # Income categories
      { name: "Salary", color: "#8BC34A", category_type: "income" },
      { name: "Freelance", color: "#CDDC39", category_type: "income" },
      { name: "Investment", color: "#009688", category_type: "income" },
      { name: "Gift", color: "#FF9800", category_type: "income" },
      { name: "Other Income", color: "#03A9F4", category_type: "income" },
      # Uncategorized
      { name: "Uncategorized", color: "#9E9E9E", category_type: "both" }
    ]

    default_categories.each do |attrs|
      Category.create!(attrs.merge(is_default: true))
    end
  end

  def down
    Category.where(is_default: true).destroy_all
  end
end
```

---

## Data Integrity & Constraints

1. **Foreign Key Constraints**: All foreign keys have `ON DELETE` rules
   - `transactions.user_id`: `ON DELETE CASCADE` (delete transactions when user deleted)
   - `transactions.category_id`: `ON DELETE RESTRICT` (prevent category deletion if has transactions)

2. **Check Constraints**:
   - `amount > 0` (enforce positive amounts)
   - `transaction_type IN ('income', 'expense')`
   - `category_type IN ('income', 'expense', 'both')`

3. **Unique Constraints**:
   - `users.email` (case-insensitive)
   - `categories(name, user_id)` for custom categories

4. **NOT NULL Constraints**:
   - All core fields (user_id, amount, date, transaction_type, category_id)

---

## Performance Considerations

1. **Indexing**: All foreign keys and frequently queried columns indexed
2. **Eager Loading**: Use `includes(:category, :user)` to prevent N+1 queries
3. **Database-level Aggregations**: Use SQL SUM/AVG instead of Ruby loops
4. **Pagination**: Limit transaction lists to 50 per page
5. **Caching**: Cache monthly summaries (invalidate on new transaction)

---

## Security Considerations

1. **Authorization**: Users can only access their own transactions/categories
2. **SQL Injection**: Use parameterized queries (ActiveRecord handles this)
3. **Mass Assignment**: Use strong parameters in controllers
4. **Password Storage**: BCrypt hashing via Devise
5. **Session Security**: CSRF tokens, secure cookies

---

## Testing Strategy

1. **Model Tests**: Validations, associations, scopes, business logic methods
2. **Factory Definitions**: FactoryBot for test data generation
3. **Database Cleaner**: Reset database between tests
4. **Edge Cases**: Test boundary conditions (max amounts, date limits, etc.)
