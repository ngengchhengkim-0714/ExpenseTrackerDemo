---
description: "Task list for Personal Finance Tracker implementation"
---

# Tasks: Personal Finance Tracker

**Input**: Design documents from `/specs/001-expense-tracker/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/, research.md, quickstart.md

**Tests**: Tests are REQUIRED per project constitution (TDD principle). All model, service, controller, and system tests are included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

Rails application structure at repository root (expense-tracker/)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Initialize Rails 7.1.2 application with Ruby 3.3.0 using `rails new expense-tracker --database=mysql --css=tailwind --javascript=importmap`
- [ ] T002 [P] Add core gems to Gemfile: devise 4.9, rspec-rails 6.1, capybara 3.39, factory_bot_rails 6.4, faker 3.2, chartkick 5.0, groupdate 6.4
- [ ] T003 [P] Add development/test gems to Gemfile: rubocop 1.60, bullet, simplecov
- [ ] T004 Run `bundle install` to install all dependencies
- [ ] T005 [P] Configure RuboCop with .rubocop.yml (Rails style guide)
- [ ] T006 [P] Initialize RSpec with `rails generate rspec:install`
- [ ] T007 [P] Configure SimpleCov in spec/rails_helper.rb for 80%+ coverage tracking
- [ ] T008 [P] Configure FactoryBot in spec/rails_helper.rb
- [ ] T009 [P] Configure Bullet gem in config/environments/development.rb for N+1 query detection
- [ ] T010 Create Docker configuration: Dockerfile for Rails app
- [ ] T011 Create docker-compose.yml with web service (Rails) and db service (MySQL 8.0)
- [ ] T012 Create .dockerignore file
- [ ] T013 Configure config/database.yml for MySQL2 adapter with Docker environment variables

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T014 Setup database with `rails db:create`
- [ ] T015 Install and configure Devise with `rails generate devise:install`
- [ ] T016 Configure Devise in config/initializers/devise.rb (session timeout 30 minutes, password complexity)
- [ ] T017 Generate Devise User model with `rails generate devise User full_name:string`
- [ ] T018 Add password complexity validation to app/models/user.rb
- [ ] T019 Create database migration for categories table in db/migrate/
- [ ] T020 Create database migration for transactions table in db/migrate/
- [ ] T021 Add database indexes to migrations (user_id, category_id, date columns)
- [ ] T022 Run migrations with `rails db:migrate`
- [ ] T023 Create Category model in app/models/category.rb with validations
- [ ] T024 Create Transaction model in app/models/transaction.rb with validations and associations
- [ ] T025 Add default categories seed data in db/seeds.rb (15 categories: Groceries, Transportation, Utilities, Rent/Mortgage, Entertainment, Healthcare, Dining Out, Shopping, Other Expense, Salary, Freelance, Investment, Gift, Other Income, Uncategorized)
- [ ] T026 Create ApplicationController authentication setup in app/controllers/application_controller.rb
- [ ] T027 Configure Rails routes in config/routes.rb (devise routes, resource routes)
- [ ] T028 Create application layout in app/views/layouts/application.html.erb with TailwindCSS, flash messages, navigation
- [ ] T029 Setup Chartkick initializer in config/initializers/chartkick.rb
- [ ] T030 Configure CORS and security headers in config/initializers/

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 4 - User Authentication & Security (Priority: P1) 🎯 MVP Foundation

**Goal**: Secure account creation, login, logout, and password management to protect financial data

**Independent Test**: Create account, login/logout, password reset flow works independently

### Tests for User Story 4 (TDD - Write First, Ensure FAIL)

- [ ] T031 [P] [US4] Create User model spec in spec/models/user_spec.rb (email validation, password complexity, associations)
- [ ] T032 [P] [US4] Create authentication request spec in spec/requests/authentication_spec.rb (sign_up, sign_in, sign_out endpoints)
- [ ] T033 [P] [US4] Create password reset request spec in spec/requests/password_reset_spec.rb
- [ ] T034 [P] [US4] Create user authentication system spec in spec/system/user_authentication_spec.rb (E2E with Capybara)

### Implementation for User Story 4

- [ ] T035 [P] [US4] Customize Devise views with `rails generate devise:views`
- [ ] T036 [P] [US4] Create Sessions controller override in app/controllers/users/sessions_controller.rb for JSON responses
- [ ] T037 [P] [US4] Create Registrations controller override in app/controllers/users/registrations_controller.rb for JSON responses
- [ ] T038 [P] [US4] Create Passwords controller override in app/controllers/users/passwords_controller.rb
- [ ] T039 [US4] Style authentication views with TailwindCSS in app/views/devise/sessions/new.html.erb
- [ ] T040 [US4] Style registration view with TailwindCSS in app/views/devise/registrations/new.html.erb
- [ ] T041 [US4] Style password reset views with TailwindCSS in app/views/devise/passwords/
- [ ] T042 [US4] Create FactoryBot factory for User in spec/factories/users.rb
- [ ] T043 [US4] Add session timeout configuration to config/initializers/devise.rb
- [ ] T044 [US4] Run all User Story 4 tests and ensure they PASS

**Checkpoint**: User authentication fully functional and tested - users can register, login, reset passwords

---

## Phase 4: User Story 1 - Record Financial Transactions (Priority: P1) 🎯 MVP Core

**Goal**: Allow users to quickly log daily income/expenses with CRUD operations

**Independent Test**: Login, add/view/edit/delete transactions. Core value delivered independently.

### Tests for User Story 1 (TDD - Write First, Ensure FAIL)

- [ ] T045 [P] [US1] Create Transaction model spec in spec/models/transaction_spec.rb (validations, associations, scopes)
- [ ] T046 [P] [US1] Create transactions request spec in spec/requests/transactions_spec.rb (index, show, create, update, destroy)
- [ ] T047 [P] [US1] Create transaction management system spec in spec/system/transaction_management_spec.rb (E2E CRUD flow)

### Implementation for User Story 1

- [ ] T048 [P] [US1] Create TransactionsController in app/controllers/transactions_controller.rb (index, show, new, create, edit, update, destroy actions)
- [ ] T049 [P] [US1] Create transactions index view in app/views/transactions/index.html.erb with filtering and sorting
- [ ] T050 [P] [US1] Create transaction show view in app/views/transactions/show.html.erb
- [ ] T051 [P] [US1] Create transaction form partial in app/views/transactions/_form.html.erb with TailwindCSS
- [ ] T052 [P] [US1] Create new transaction view in app/views/transactions/new.html.erb
- [ ] T053 [P] [US1] Create edit transaction view in app/views/transactions/edit.html.erb
- [ ] T054 [US1] Create TransactionFormComponent in app/components/transaction_form_component.rb (ViewComponent for reusable form UI)
- [ ] T055 [US1] Add Transaction scopes in app/models/transaction.rb (by_date_range, by_type, by_category, recent)
- [ ] T056 [US1] Create Stimulus controller for transaction form in app/javascript/controllers/transaction_form_controller.js (dynamic amount formatting, date picker)
- [ ] T057 [US1] Create FactoryBot factory for Transaction in spec/factories/transactions.rb
- [ ] T058 [US1] Add transaction filtering logic to TransactionsController
- [ ] T059 [US1] Add validation error handling and flash messages
- [ ] T060 [US1] Run all User Story 1 tests and ensure they PASS

**Checkpoint**: Core transaction CRUD complete - users can track income/expenses independently

---

## Phase 5: User Story 2 - Categorize Transactions (Priority: P2)

**Goal**: Organize transactions into categories for spending pattern analysis

**Independent Test**: Add transactions, assign/change categories, filter by category. Delivers organizational value independently.

### Tests for User Story 2 (TDD - Write First, Ensure FAIL)

- [ ] T061 [P] [US2] Create Category model spec in spec/models/category_spec.rb (validations, uniqueness, default categories)
- [ ] T062 [P] [US2] Create categories request spec in spec/requests/categories_spec.rb (index, create, update, destroy)
- [ ] T063 [P] [US2] Create categorization system spec in spec/system/categorization_spec.rb (E2E assign, bulk assign, filter)

### Implementation for User Story 2

- [ ] T064 [P] [US2] Create CategoriesController in app/controllers/categories_controller.rb (index, create, update, destroy)
- [ ] T065 [P] [US2] Create categories index view in app/views/categories/index.html.erb with color-coded badges
- [ ] T066 [P] [US2] Create category form partial in app/views/categories/_form.html.erb with color picker
- [ ] T067 [US2] Create CategoryBadgeComponent in app/components/category_badge_component.rb (ViewComponent for colored category display)
- [ ] T068 [US2] Add category dropdown to transaction form in app/views/transactions/_form.html.erb
- [ ] T069 [US2] Create Stimulus controller for category filter in app/javascript/controllers/filter_controller.js
- [ ] T070 [US2] Create FactoryBot factory for Category in spec/factories/categories.rb
- [ ] T071 [US2] Add bulk categorization action to TransactionsController (bulk_update)
- [ ] T072 [US2] Implement custom category creation/deletion with transaction reassignment logic
- [ ] T073 [US2] Add category filtering to transactions index view
- [ ] T074 [US2] Run all User Story 2 tests and ensure they PASS

**Checkpoint**: Categorization complete - users can organize and filter transactions by category

---

## Phase 6: User Story 3 - Generate Monthly Reports (Priority: P3)

**Goal**: Visual summaries and trend analysis for informed financial decisions

**Independent Test**: With categorized transactions, view monthly/yearly reports with charts. Analytical insights delivered independently.

### Tests for User Story 3 (TDD - Write First, Ensure FAIL)

- [ ] T075 [P] [US3] Create MonthlySummaryService spec in spec/services/reports/monthly_summary_service_spec.rb
- [ ] T076 [P] [US3] Create TrendAnalyzerService spec in spec/services/reports/trend_analyzer_service_spec.rb
- [ ] T077 [P] [US3] Create reports request spec in spec/requests/reports_spec.rb (monthly, trends)
- [ ] T078 [P] [US3] Create reports viewing system spec in spec/system/reports_viewing_spec.rb (E2E chart interaction, period selection)

### Implementation for User Story 3

- [ ] T079 [P] [US3] Create MonthlySummaryService in app/services/reports/monthly_summary_service.rb (calculate totals, category breakdown, percentages)
- [ ] T080 [P] [US3] Create TrendAnalyzerService in app/services/reports/trend_analyzer_service.rb (6-month trends, averages)
- [ ] T081 [P] [US3] Create ReportsController in app/controllers/reports_controller.rb (monthly, trends actions)
- [ ] T082 [P] [US3] Create reports index view in app/views/reports/index.html.erb with period selector
- [ ] T083 [US3] Create monthly report view in app/views/reports/monthly.html.erb with Chartkick pie/bar charts
- [ ] T084 [US3] Create trends report view in app/views/reports/trends.html.erb with Chartkick line chart
- [ ] T085 [US3] Create ChartComponent in app/components/chart_component.rb (ViewComponent for reusable charts)
- [ ] T086 [US3] Create Stimulus controller for chart interactions in app/javascript/controllers/chart_controller.js
- [ ] T087 [US3] Add report caching in ReportsController (5-minute cache, invalidate on transaction change)
- [ ] T088 [US3] Create ReportsHelper in app/helpers/reports_helper.rb (currency formatting, percentage calculations)
- [ ] T089 [US3] Add date range picker to reports view
- [ ] T090 [US3] Implement drill-down from chart to transaction list
- [ ] T091 [US3] Run all User Story 3 tests and ensure they PASS

**Checkpoint**: All core user stories complete - full expense tracking application functional

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T092 [P] Create comprehensive seed data in db/seeds.rb (10 demo users with 50-200 transactions each, 6-month date range using Faker)
- [ ] T093 [P] Add responsive mobile styles to all views (320px+ width, touch-friendly buttons 44x44px)
- [ ] T094 [P] Add loading states with Turbo Frame indicators for async operations
- [ ] T095 [P] Implement error pages in app/views/errors/ (404.html.erb, 500.html.erb)
- [ ] T096 [P] Add ARIA labels and semantic HTML for WCAG 2.1 Level AA accessibility
- [ ] T097 Create shared navigation partial in app/views/shared/_header.html.erb
- [ ] T098 Create shared footer partial in app/views/shared/_footer.html.erb
- [ ] T099 Add flash message styling in app/views/shared/_flash.html.erb
- [ ] T100 [P] Optimize database queries with eager loading (includes, joins)
- [ ] T101 [P] Add database indexes verification and optimization
- [ ] T102 [P] Run RuboCop and fix all linting issues
- [ ] T103 [P] Run SimpleCov and ensure 80%+ test coverage
- [ ] T104 Update README.md with quickstart instructions from specs/001-expense-tracker/quickstart.md
- [ ] T105 Run `docker-compose build` and verify containerization
- [ ] T106 Run `docker-compose up` and test full application in Docker
- [ ] T107 Execute quickstart.md validation (create demo account, add transactions, generate report)
- [ ] T108 Performance testing (API response <200ms p95, page load <3s on 3G simulation)
- [ ] T109 Security audit (session timeout, password encryption, CSRF protection, SQL injection prevention)
- [ ] T110 [P] Create API documentation from contracts/ in docs/api/

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 4 (Phase 3)**: Depends on Foundational (Phase 2) - Authentication must work first (P1)
- **User Story 1 (Phase 4)**: Depends on User Story 4 completion - Users must login to add transactions (P1)
- **User Story 2 (Phase 5)**: Depends on User Story 1 completion - Transactions must exist to categorize (P2)
- **User Story 3 (Phase 6)**: Depends on User Story 2 completion - Categorized data needed for meaningful reports (P3)
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

```
Foundation (Phase 2)
        ↓
    US4: Auth (P1) ← Must complete first
        ↓
    US1: Transactions (P1) ← Core functionality
        ↓
    US2: Categories (P2) ← Organizes transactions
        ↓
    US3: Reports (P3) ← Analyzes categorized data
```

### Within Each User Story

1. **Tests FIRST** (TDD): Write all tests for the story, ensure they FAIL
2. **Models**: Database layer with validations
3. **Services**: Business logic for complex operations
4. **Controllers**: HTTP request handling
5. **Views**: User interface with TailwindCSS
6. **JavaScript**: Stimulus controllers for interactivity
7. **Tests PASS**: Run all tests for the story, ensure they PASS

### Parallel Opportunities

**Phase 1 (Setup)**: Tasks T002, T003, T005, T006, T007, T008, T009 can run in parallel after T001

**Phase 2 (Foundational)**: After migrations are created (T019-T021), T023-T024 (models) can be worked on in parallel with T026-T030 (infrastructure)

**Phase 3 (US4 - Auth)**:
- Tests T031-T034 can all be written in parallel
- Controllers T036-T038 can be implemented in parallel
- Views T039-T041 can be styled in parallel

**Phase 4 (US1 - Transactions)**:
- Tests T045-T047 can all be written in parallel
- Views T049-T053 can be created in parallel

**Phase 5 (US2 - Categories)**:
- Tests T061-T063 can all be written in parallel
- Views T065-T066 can be created in parallel

**Phase 6 (US3 - Reports)**:
- Tests T075-T078 can all be written in parallel
- Services T079-T080 can be implemented in parallel
- Views T082-T084 can be created in parallel

**Phase 7 (Polish)**: Most tasks T092-T096 and T100-T103 can run in parallel (different concerns)

---

## Parallel Example: User Story 1 (Transactions)

```bash
# Step 1: Write all tests in parallel (different test files)
Task T045: spec/models/transaction_spec.rb
Task T046: spec/requests/transactions_spec.rb
Task T047: spec/system/transaction_management_spec.rb

# Run tests - they should all FAIL (TDD red phase)

# Step 2: Create views in parallel (different view files)
Task T049: app/views/transactions/index.html.erb
Task T050: app/views/transactions/show.html.erb
Task T051: app/views/transactions/_form.html.erb
Task T052: app/views/transactions/new.html.erb
Task T053: app/views/transactions/edit.html.erb

# Step 3: Implement controller and component sequentially
Task T048: app/controllers/transactions_controller.rb
Task T054: app/components/transaction_form_component.rb

# Step 4: Add enhancements
Task T055-T060 sequentially

# Run tests - they should all PASS (TDD green phase)
```

---

## Implementation Strategy

### MVP First (Minimum Viable Product)

**Goal**: Deliver basic expense tracking as fast as possible

1. **Phase 1**: Setup (T001-T013)
2. **Phase 2**: Foundational (T014-T030) - CRITICAL
3. **Phase 3**: User Story 4 - Authentication (T031-T044)
4. **Phase 4**: User Story 1 - Transactions (T045-T060)
5. **STOP and VALIDATE**: Test independently with demo user
6. **Deploy/Demo**: Users can now register and track expenses (MVP achieved!)

**Value**: Users get immediate value - secure login and transaction tracking

---

### Incremental Delivery (Recommended)

**Goal**: Each phase adds testable value

1. **Foundation**: Phase 1 + Phase 2 (T001-T030)
   - **Result**: Rails app with database and authentication setup

2. **MVP Release**: Add Phase 3 + Phase 4 (T031-T060)
   - **Result**: User registration, login, CRUD transactions
   - **Test**: Create account → Add 5 transactions → View list → Edit one → Delete one
   - **Deploy**: First usable version!

3. **Categorization Release**: Add Phase 5 (T061-T074)
   - **Result**: Organize transactions by category
   - **Test**: Assign categories → Filter by category → Create custom category
   - **Deploy**: Users can organize spending!

4. **Analytics Release**: Add Phase 6 (T075-T091)
   - **Result**: Visual reports and trend analysis
   - **Test**: View monthly report → See pie chart → View 6-month trend → Drill down to transactions
   - **Deploy**: Users get financial insights!

5. **Production Release**: Add Phase 7 (T092-T110)
   - **Result**: Polished, performant, accessible, production-ready
   - **Test**: Full quickstart.md validation → Load test → Security audit
   - **Deploy**: Ready for real users!

**Each release is independently functional and adds clear value**

---

### Parallel Team Strategy (Advanced)

**With 3+ developers available:**

1. **All together**: Phase 1 + Phase 2 (Foundation) - ~2-3 days
2. **Phase 3 complete**: User Story 4 (Auth) - Must finish first - ~1 day
3. **Once Auth is done, split work**:
   - **Developer A**: Phase 4 (User Story 1 - Transactions)
   - **Developer B**: Phase 5 (User Story 2 - Categories) - after US1 models done
   - **Developer C**: Phase 6 (User Story 3 - Reports) - after US2 services done
4. **Integration**: Merge and test all stories together
5. **All together**: Phase 7 (Polish) - ~1-2 days

**Timeline**: ~1-2 weeks vs 3-4 weeks sequential

---

## Testing Strategy (TDD Workflow)

### Red-Green-Refactor Cycle

For each user story:

1. **RED**: Write test first, run it, watch it FAIL
   ```bash
   bundle exec rspec spec/models/transaction_spec.rb
   # Expected: FAIL (feature not implemented yet)
   ```

2. **GREEN**: Write minimal code to make test PASS
   ```bash
   # Implement feature
   bundle exec rspec spec/models/transaction_spec.rb
   # Expected: PASS
   ```

3. **REFACTOR**: Clean up code while keeping tests GREEN
   ```bash
   # Improve code quality
   bundle exec rspec spec/models/transaction_spec.rb
   # Expected: Still PASS
   ```

### Test Execution Commands

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run specific test by line number
bundle exec rspec spec/models/user_spec.rb:23

# Run tests for a specific user story
bundle exec rspec spec/models/transaction_spec.rb spec/requests/transactions_spec.rb

# Run with coverage report
COVERAGE=true bundle exec rspec

# Run system tests (E2E with Capybara)
bundle exec rspec spec/system/
```

### Coverage Goals

- **Overall**: 80%+ (enforced by SimpleCov)
- **Models**: 95%+ (core business logic)
- **Controllers**: 85%+ (request specs)
- **Services**: 90%+ (complex business rules)
- **System**: 80%+ (critical user flows)

---

## Quality Gates

**Before considering a phase complete:**

1. ✅ All tests for that phase PASS
2. ✅ RuboCop shows no offenses: `bundle exec rubocop`
3. ✅ Coverage meets threshold: `COVERAGE=true bundle exec rspec`
4. ✅ Bullet detects no N+1 queries (check logs)
5. ✅ Manual testing of happy path
6. ✅ Edge cases verified (empty states, validation errors)

**Before production deployment:**

1. ✅ All 110 tasks complete
2. ✅ Quickstart.md validation passes
3. ✅ Docker build successful: `docker-compose build`
4. ✅ Docker deployment works: `docker-compose up`
5. ✅ Performance targets met (API <200ms, page load <3s)
6. ✅ Security audit clean
7. ✅ Accessibility WCAG 2.1 Level AA verified

---

## Notes

- **[P] markers**: Tasks that can run in parallel (different files, no blocking dependencies)
- **[Story] labels**: Map tasks to user stories from spec.md for traceability
- **TDD emphasis**: Every feature has tests written FIRST (red), then implementation (green)
- **Rails conventions**: Follow MVC pattern, fat models/skinny controllers, service objects for complex logic
- **Commit strategy**: Commit after each task or logical group (e.g., all tests for a story)
- **Checkpoints**: Stop at each checkpoint to validate the story works independently
- **RuboCop**: Run frequently to catch style issues early
- **Bullet gem**: Monitor development logs for N+1 query warnings

**Total Tasks**: 110 tasks organized in 7 phases for complete expense tracker implementation with Rails, MySQL, Docker, comprehensive testing, and production-ready polish.
