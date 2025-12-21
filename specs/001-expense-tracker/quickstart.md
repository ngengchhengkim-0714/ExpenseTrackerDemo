# Quickstart Guide: Personal Finance Tracker

**Date**: 2025-12-21
**Feature**: Personal Finance Tracker
**Branch**: 001-expense-tracker

## Prerequisites

- Docker Desktop 20.10+ and Docker Compose 2.x
- Git 2.30+
- Text editor (VS Code recommended)
- Modern web browser (Chrome 90+, Firefox 88+, Safari 14+)

---

## Quick Start with Docker

### 1. Clone and Setup

```bash
# Clone repository
git clone <repository-url>
cd expense-tracker

# Checkout feature branch
git checkout 001-expense-tracker

# Create environment file
cp .env.example .env
```

### 2. Start with Docker Compose

```bash
# Build and start containers
docker-compose up --build

# Application will be available at http://localhost:3000
```

The `docker-compose.yml` starts:
- **web**: Rails app on port 3000
- **db**: MySQL 8.0 on port 3306

### 3. Setup Database with Mock Data

```bash
# In another terminal, run database setup
docker-compose exec web bin/rails db:create db:migrate db:seed

# This creates:
# - Database schema (users, transactions, categories)
# - Default categories (15 categories)
# - 10 demo users with transactions
```

### 4. Access Demo Accounts

```
User 1: demo1@example.com / Password123!
User 2: demo2@example.com / Password123!
...
User 10: demo10@example.com / Password123!
```

Each demo user has:
- 50-200 random transactions over 6 months
- Mix of income and expenses
- Various categories assigned

---

## Local Development (Without Docker)

### 1. Install Dependencies

```bash
# Install Ruby 3.3.0 (using rbenv or rvm)
rbenv install 3.3.0
rbenv local 3.3.0

# Install Bundler
gem install bundler

# Install gems
bundle install

# Install Node.js dependencies (for Tailwind)
npm install
```

### 2. Configure Database

Edit `config/database.yml`:
```yaml
development:
  adapter: mysql2
  encoding: utf8mb4
  database: expense_tracker_development
  username: root
  password: your_password
  host: localhost
  port: 3306
```

### 3. Setup Database

```bash
# Create and migrate
bin/rails db:create db:migrate

# Seed default categories and demo data
bin/rails db:seed
```

### 4. Start Development Server

```bash
# Start Rails server
bin/rails server

# In another terminal, start Tailwind watcher
bin/rails tailwindcss:watch

# Application at http://localhost:3000
```

---

## Running Tests

### Full Test Suite

```bash
# With Docker
docker-compose exec web bundle exec rspec

# Without Docker
bundle exec rspec
```

### Specific Test Types

```bash
# Model tests only
bundle exec rspec spec/models

# Request specs (integration tests)
bundle exec rspec spec/requests

# System specs (E2E with Capybara)
bundle exec rspec spec/system

# With coverage report
COVERAGE=true bundle exec rspec
```

### Test Output

```
Finished in 15.3 seconds (files took 2.5 seconds to load)
150 examples, 0 failures

Coverage: 87.5%
```

---

## Code Quality Checks

### Linting with RuboCop

```bash
# Check code style
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# Check specific files
bundle exec rubocop app/models/user.rb
```

### Security Audit

```bash
# Check for security vulnerabilities
bundle exec brakeman

# Check gem vulnerabilities
bundle exec bundle audit check --update
```

---

## Database Management

### Migrations

```bash
# Create new migration
bin/rails generate migration AddFieldToTable field:type

# Run pending migrations
bin/rails db:migrate

# Rollback last migration
bin/rails db:rollback

# Check migration status
bin/rails db:migrate:status
```

### Console Access

```bash
# Rails console
bin/rails console

# In console
User.count
Transaction.where(transaction_type: 'income').sum(:amount)
Category.where(is_default: true).pluck(:name)
```

### Reset Database

```bash
# Drop, create, migrate, seed
bin/rails db:reset

# Or with Docker
docker-compose exec web bin/rails db:reset
```

---

## Mock Data Generation

### Seed File Structure

The `db/seeds.rb` file generates:

1. **Default Categories** (15 categories):
   - 9 expense categories
   - 5 income categories
   - 1 uncategorized

2. **Demo Users** (10 users):
   - `demo1@example.com` to `demo10@example.com`
   - All passwords: `Password123!`

3. **Transactions** (per user):
   - 50-200 random transactions
   - Dates: Last 6 months
   - Amounts: $5 to $500
   - Realistic descriptions using Faker
   - Proper category assignments

### Customize Mock Data

Edit `db/seeds.rb`:

```ruby
# Change number of users
NUM_DEMO_USERS = 20

# Change transaction count per user
MIN_TRANSACTIONS = 100
MAX_TRANSACTIONS = 300

# Change date range
START_DATE = 12.months.ago
END_DATE = Date.today
```

Then re-seed:
```bash
bin/rails db:seed:replant  # Clears and re-seeds
```

---

## Testing User Workflows

### 1. User Registration & Login

```bash
# Visit homepage
open http://localhost:3000

# Click "Sign Up"
# Fill form: email, password, full name
# Submit → redirected to dashboard
```

### 2. Add Transaction

```bash
# On dashboard, click "Add Transaction"
# Fill form:
#   - Amount: 50.00
#   - Description: "Weekly groceries"
#   - Type: Expense
#   - Category: Groceries
#   - Date: Today
# Submit → transaction appears in list
```

### 3. View Reports

```bash
# Click "Reports" in navigation
# See:
#   - Monthly summary (income, expense, net)
#   - Category breakdown pie chart
#   - 6-month trend line chart
# Select different month → report updates
```

### 4. Manage Categories

```bash
# Click "Categories"
# See default + custom categories
# Click "Add Category"
#   - Name: "Subscriptions"
#   - Color: #9C27B0
#   - Type: Expense
# Submit → available for transactions
```

---

## API Testing with curl

### Authentication

```bash
# Register user
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"Password123!","password_confirmation":"Password123!","full_name":"Test User"}}'

# Login (saves cookie)
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -c cookies.txt \
  -d '{"user":{"email":"test@example.com","password":"Password123!"}}'
```

### Transactions

```bash
# Create transaction
curl -X POST http://localhost:3000/transactions \
  -H "Content-Type: application/json" \
  -b cookies.txt \
  -d '{"transaction":{"amount":"50.00","description":"Groceries","transaction_type":"expense","date":"2025-12-20","category_id":1}}'

# List transactions
curl http://localhost:3000/transactions \
  -b cookies.txt

# Monthly summary
curl "http://localhost:3000/transactions/summary?start_date=2025-12-01&end_date=2025-12-31" \
  -b cookies.txt
```

---

## Performance Testing

### Load Testing with Apache Bench

```bash
# Test homepage
ab -n 1000 -c 10 http://localhost:3000/

# Test dashboard (authenticated)
ab -n 500 -c 5 -C "session_id=..." http://localhost:3000/dashboard
```

### Database Query Analysis

```ruby
# In Rails console
User.first.transactions.includes(:category).explain

# Check for N+1 queries
Bullet.enable = true  # In development.rb
# Visit pages and check logs
```

---

## Troubleshooting

### Docker Issues

```bash
# Container won't start
docker-compose logs web
docker-compose logs db

# Database connection refused
docker-compose restart db
bin/rails db:migrate

# Port already in use
# Change port in docker-compose.yml: "3001:3000"
```

### Database Issues

```bash
# Connection errors
# Check config/database.yml matches docker-compose.yml

# Migration errors
bin/rails db:migrate:status
bin/rails db:rollback
# Fix migration, then db:migrate again
```

### Test Failures

```bash
# Clear test database
RAILS_ENV=test bin/rails db:reset

# Check for leftover data
RAILS_ENV=test bin/rails console
Transaction.count  # Should be 0 before test run
```

---

## Next Steps

1. **Run Tests**: `bundle exec rspec` (80%+ coverage required)
2. **Check Linting**: `bundle exec rubocop` (0 offenses required)
3. **Review Constitution**: Ensure compliance with quality gates
4. **Create Tasks**: Run `/speckit.tasks` to generate implementation tasks
5. **Start Development**: Follow TDD workflow for each task

---

## Development Workflow

1. **Create Feature Branch**: `git checkout -b feature/your-feature`
2. **Write Test First**: Create spec file, write failing test
3. **Implement Feature**: Write minimal code to pass test
4. **Refactor**: Improve code while keeping tests green
5. **Check Coverage**: `COVERAGE=true bundle exec rspec`
6. **Lint Code**: `bundle exec rubocop -a`
7. **Commit**: `git commit -m "feat: descriptive message"`
8. **Push**: `git push origin feature/your-feature`
9. **Pull Request**: Request review, ensure CI passes

---

## Useful Commands Reference

```bash
# Docker
docker-compose up          # Start containers
docker-compose down        # Stop containers
docker-compose exec web bash  # Shell into web container

# Rails
bin/rails server           # Start server
bin/rails console          # Interactive console
bin/rails routes           # Show all routes
bin/rails db:migrate       # Run migrations
bin/rails db:seed          # Seed data

# Testing
bundle exec rspec          # Run all tests
bundle exec rspec --format documentation  # Detailed output
bundle exec rspec --tag focus  # Run focused tests only

# Linting
bundle exec rubocop        # Check style
bundle exec rubocop -a     # Auto-fix
bundle exec brakeman       # Security audit
```

---

## Resources

- **Rails Guides**: https://guides.rubyonrails.org/
- **RSpec Documentation**: https://rspec.info/
- **TailwindCSS**: https://tailwindcss.com/docs
- **Devise**: https://github.com/heartcombo/devise
- **Project Constitution**: `.specify/memory/constitution.md`
