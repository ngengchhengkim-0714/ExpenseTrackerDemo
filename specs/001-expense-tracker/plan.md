# Implementation Plan: Personal Finance Tracker

**Branch**: `001-expense-tracker` | **Date**: 2025-12-21 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-expense-tracker/spec.md`

**Note**: This plan follows Ruby on Rails MVC architecture with MySQL2, Docker-compose for deployment, and comprehensive testing strategy.

## Summary

Build a responsive web application using Ruby on Rails (both frontend and backend) for personal finance tracking with user authentication, transaction management, categorization, and monthly reporting. The application will use Turbo and Stimulus for modern interactive UI without requiring separate frontend framework, MySQL2 for data persistence, RSpec/Capybara for testing, and Docker-compose for containerized deployment with seed data.

## Technical Context

**Language/Version**: Ruby 3.3.0 / Rails 7.1.2
**Primary Dependencies**:
- Rails 7.1.2 (web framework with Turbo/Stimulus for frontend interactivity)
- Devise 4.9 (authentication)
- MySQL2 adapter for ActiveRecord
- RSpec-Rails 6.1 (testing framework)
- Capybara 3.39 (integration/E2E testing)
- FactoryBot 6.4 (test fixtures)
- Faker 3.2 (mock data generation)
- Chartkick 5.0 + Groupdate 6.4 (charts for reports)
- TailwindCSS 3.4 (styling)
- RuboCop 1.60 (linting)

**Storage**: MySQL 8.0 (relational database)
**Testing**: RSpec (unit/integration), Capybara + Selenium (E2E), SimpleCov (coverage)
**Target Platform**: Linux containers (Docker), web browsers (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
**Project Type**: Web application (Rails monolith with Hotwire for SPA-like experience)
**Performance Goals**:
- API response <200ms p95
- Page load <3s on 3G
- Database queries optimized with proper indexing
- Support 1000+ concurrent sessions

**Constraints**:
- All monetary calculations use decimal precision (no floats)
- Session timeout 30 minutes
- Mobile-first responsive design (320px+ width)
- WCAG 2.1 Level AA accessibility
- 80%+ test coverage minimum

**Scale/Scope**:
- ~5,000 users
- ~100,000 transactions/month
- 6 core models
- ~20 controller actions
- ~15 views/partials

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Code Quality First ✓

- [x] Linting and formatting tools configured (RuboCop with Rails style guide)
- [x] Code review process defined (PR reviews before merge)
- [x] Dependencies explicitly declared with version pinning (Gemfile.lock)
- [x] Module structure follows SOLID principles (Rails MVC + Service Objects pattern)

**Status**: PASS
**Notes**: Rails MVC naturally enforces separation of concerns. RuboCop will enforce Ruby/Rails style guide. Service objects for complex business logic.

### II. Test-Driven Development (TDD) ✓

- [x] Test framework selected and configured (RSpec + Capybara + FactoryBot)
- [x] Unit test structure defined (models, services - 80%+ coverage target)
- [x] Integration test approach planned (request specs for API endpoints)
- [x] E2E tests for critical paths identified (Capybara for user flows)
- [x] Tests planned before implementation (TDD workflow)

**Status**: PASS
**Notes**: RSpec for unit/integration tests, Capybara for E2E, SimpleCov for coverage tracking. Model specs, controller specs, system specs structure defined.

### III. User Experience Consistency ✓

- [x] Design system or component library defined (TailwindCSS + ViewComponents)
- [x] Responsive breakpoints planned (mobile 320px+, tablet 768px+, desktop 1024px+)
- [x] Touch targets meet 44x44px minimum on mobile (Tailwind spacing utilities)
- [x] Loading states defined for >300ms operations (Turbo Frame loading indicators)
- [x] Error message patterns established (Rails flash messages + inline validations)
- [x] Accessibility requirements planned (WCAG 2.1 Level AA, semantic HTML, ARIA labels)

**Status**: PASS
**Notes**: TailwindCSS provides responsive utilities. Turbo Frames for SPA-like experience. ViewComponents for reusable UI. Semantic HTML + ARIA for accessibility.

### IV. Performance & Responsiveness ✓

- [x] Initial load time target defined (<3s on 3G with Turbo)
- [x] Core Web Vitals targets set (LCP <2.5s, FID <100ms, CLS <0.1)
- [x] API response time targets defined (<200ms p95 with ActiveRecord optimization)
- [x] Database query optimization planned (proper indexing, eager loading, no N+1)
- [x] Image optimization strategy defined (ActiveStorage with ImageMagick, lazy loading)
- [x] Bundle size budget set (Sprockets asset pipeline, minimal JS with Stimulus)
- [x] Performance monitoring tools selected (Rails built-in instrumentation, Bullet gem for N+1 detection)

**Status**: PASS
**Notes**: Turbo for fast page transitions. Database indexes on foreign keys and query columns. Bullet gem to detect N+1 queries during development.

### Overall Constitution Compliance

**Assessment**: APPROVED

**Conditions/Action Items**: None - all principles satisfied by Rails conventions and selected tools.

## Project Structure

### Documentation (this feature)

```text
specs/001-expense-tracker/
├── plan.md              # This file
├── research.md          # Technology decisions and rationale
├── data-model.md        # Database schema and entities
├── quickstart.md        # Development setup and testing guide
├── contracts/           # API endpoint documentation
│   ├── authentication.yml
│   ├── transactions.yml
│   ├── categories.yml
│   └── reports.yml
└── checklists/
    └── requirements.md  # Specification quality checklist
```

### Source Code (repository root)

```text
expense-tracker/              # Rails application root
├── app/
│   ├── models/              # ActiveRecord models
│   │   ├── user.rb
│   │   ├── transaction.rb
│   │   ├── category.rb
│   │   └── concerns/        # Shared model behaviors
│   ├── controllers/         # HTTP request handlers
│   │   ├── application_controller.rb
│   │   ├── sessions_controller.rb
│   │   ├── registrations_controller.rb
│   │   ├── transactions_controller.rb
│   │   ├── categories_controller.rb
│   │   └── reports_controller.rb
│   ├── views/              # ERB templates
│   │   ├── layouts/
│   │   │   └── application.html.erb
│   │   ├── sessions/
│   │   ├── registrations/
│   │   ├── transactions/
│   │   ├── categories/
│   │   ├── reports/
│   │   └── shared/         # Reusable partials
│   ├── components/         # ViewComponents for reusable UI
│   │   ├── transaction_form_component.rb
│   │   ├── category_badge_component.rb
│   │   └── chart_component.rb
│   ├── services/           # Business logic layer
│   │   ├── reports/
│   │   │   ├── monthly_summary_service.rb
│   │   │   └── trend_analyzer_service.rb
│   │   └── transactions/
│   │       └── bulk_categorizer_service.rb
│   ├── javascript/         # Stimulus controllers
│   │   ├── application.js
│   │   └── controllers/
│   │       ├── transaction_form_controller.js
│   │       ├── chart_controller.js
│   │       └── filter_controller.js
│   ├── assets/
│   │   ├── stylesheets/
│   │   │   └── application.tailwind.css
│   │   └── images/
│   └── helpers/            # View helpers
│       ├── application_helper.rb
│       └── reports_helper.rb
├── config/
│   ├── routes.rb          # URL routing
│   ├── database.yml       # MySQL connection config
│   ├── environments/      # Environment-specific configs
│   │   ├── development.rb
│   │   ├── test.rb
│   │   └── production.rb
│   └── initializers/      # Framework initializers
│       ├── devise.rb
│       └── chartkick.rb
├── db/
│   ├── migrate/           # Database migrations
│   │   ├── 20251221_devise_create_users.rb
│   │   ├── 20251221_create_categories.rb
│   │   └── 20251221_create_transactions.rb
│   ├── seeds.rb           # Mock data generation
│   └── schema.rb          # Current database structure
├── spec/                  # RSpec tests
│   ├── models/
│   │   ├── user_spec.rb
│   │   ├── transaction_spec.rb
│   │   └── category_spec.rb
│   ├── requests/          # Integration tests
│   │   ├── authentication_spec.rb
│   │   ├── transactions_spec.rb
│   │   ├── categories_spec.rb
│   │   └── reports_spec.rb
│   ├── system/            # E2E tests with Capybara
│   │   ├── user_authentication_spec.rb
│   │   ├── transaction_management_spec.rb
│   │   ├── categorization_spec.rb
│   │   └── reports_viewing_spec.rb
│   ├── services/          # Service object tests
│   ├── factories/         # FactoryBot definitions
│   │   ├── users.rb
│   │   ├── transactions.rb
│   │   └── categories.rb
│   └── rails_helper.rb
├── docker-compose.yml     # Container orchestration
├── Dockerfile            # App container definition
├── .dockerignore
├── Gemfile               # Ruby dependencies
├── Gemfile.lock
├── .rubocop.yml          # Linting configuration
├── .rspec                # RSpec configuration
└── README.md
```

**Structure Decision**: Rails monolith with Hotwire (Turbo + Stimulus) for modern frontend interactivity without separate frontend framework. Service objects pattern for complex business logic. ViewComponents for reusable UI elements. RSpec for comprehensive testing with clear separation between unit, integration, and system tests.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**Status**: No violations - all constitution requirements satisfied.

The Rails monolith with Hotwire approach provides:
- Single codebase simplicity (vs separate frontend/backend)
- Built-in conventions reducing decision fatigue
- Service objects for complex logic without over-engineering
- Standard MVC pattern with clear separation of concerns

No complexity justifications needed.
