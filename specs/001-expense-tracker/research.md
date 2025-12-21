# Research: Personal Finance Tracker Technology Stack

**Date**: 2025-12-21
**Feature**: Personal Finance Tracker
**Branch**: 001-expense-tracker

## Overview

This document captures technology decisions, rationale, and alternatives considered for the expense tracking web application.

## Core Technology Decisions

### 1. Ruby on Rails 7.1 (Full-Stack Framework)

**Decision**: Use Ruby on Rails for both backend API and frontend rendering

**Rationale**:
- **Convention over Configuration**: Rails provides sensible defaults that accelerate development while maintaining quality
- **Monolithic Simplicity**: Single codebase reduces deployment complexity and operational overhead
- **Hotwire/Turbo**: Modern SPA-like experience without separate JavaScript framework
- **Mature Ecosystem**: Extensive gem library for authentication (Devise), testing (RSpec), and visualization (Chartkick)
- **Developer Productivity**: Rails generators, ActiveRecord ORM, and built-in asset pipeline streamline development
- **Security Built-in**: CSRF protection, SQL injection prevention, XSS filtering out of the box

**Alternatives Considered**:
- **Separate React + Rails API**: More complex deployment, higher learning curve, overkill for this use case
- **Next.js + Node.js**: Different ecosystem, less mature for financial data handling
- **Django + Python**: Similar benefits but team has Rails expertise

**Best Practices**:
- Follow Rails MVC pattern strictly
- Use Service Objects for complex business logic
- Leverage ActiveRecord callbacks judiciously
- Keep controllers thin (<10 lines per action)

### 2. MySQL 8.0 (Database)

**Decision**: MySQL 8.0 with mysql2 adapter

**Rationale**:
- **ACID Compliance**: Critical for financial data integrity
- **Decimal Precision**: Native DECIMAL type for monetary calculations (avoids float rounding errors)
- **Performance**: Excellent performance for read-heavy workloads (reports, dashboards)
- **Index Support**: B-tree indexes for efficient queries on date ranges and categories
- **Window Functions**: Supports complex aggregations for trend analysis
- **Wide Adoption**: Extensive documentation and community support

**Alternatives Considered**:
- **PostgreSQL**: Equally good choice, MySQL selected for team familiarity
- **SQLite**: Not suitable for multi-user production deployment
- **MongoDB**: Overkill for structured financial data with clear relationships

**Schema Design Principles**:
- Use `DECIMAL(10, 2)` for all monetary amounts
- Index foreign keys and frequently queried columns (date, user_id, category_id)
- Use database constraints (NOT NULL, UNIQUE) for data integrity
- Soft deletes for transactions (preserve financial history)

### 3. Devise (Authentication)

**Decision**: Devise gem for user authentication

**Rationale**:
- **Battle-Tested**: Industry standard with 10+ years of production use
- **Comprehensive Features**: Registration, login, password reset, session management out of the box
- **Security**: BCrypt password hashing, token expiration, account lockout after failed attempts
- **Customizable**: Easy to extend for custom requirements
- **Rails Integration**: Seamless integration with Rails routing and controllers

**Alternatives Considered**:
- **Custom Authentication**: Higher risk, more development time, potential security issues
- **OmniAuth (OAuth)**: Adds complexity, future feature
- **Sorcery**: Less feature-complete than Devise

**Configuration**:
- 30-minute session timeout (`:timeout_in`)
- Password complexity validation (min 8 chars, uppercase, lowercase, number, special char)
- Account confirmation via email
- Password reset with 1-hour token expiration

### 4. RSpec + Capybara + FactoryBot (Testing)

**Decision**: RSpec for testing framework with Capybara for E2E and FactoryBot for fixtures

**Rationale**:
- **RSpec**: More expressive than Minitest, better for behavior-driven development
- **Capybara**: Simulates user interaction for integration/E2E tests
- **FactoryBot**: Flexible test data generation, better than fixtures for complex scenarios
- **SimpleCov**: Integrated coverage reporting to ensure 80%+ coverage

**Test Structure**:
- **Model Specs**: Validations, associations, business logic methods
- **Request Specs**: API endpoint behavior, authentication, authorization
- **System Specs**: Full user workflows with Capybara (Selenium WebDriver)
- **Service Specs**: Complex business logic in service objects

**Best Practices**:
- Follow AAA pattern (Arrange-Act-Assert)
- One assertion per test when possible
- Use `let` and `let!` for test data setup
- Tag slow tests (E2E) to run separately in CI

### 5. TailwindCSS (Styling)

**Decision**: TailwindCSS for utility-first styling

**Rationale**:
- **Responsive Out of Box**: Mobile-first utilities (sm:, md:, lg:, xl:)
- **Consistency**: Design tokens ensure consistent spacing, colors, typography
- **Performance**: PurgeCSS removes unused styles in production
- **Developer Experience**: No context switching between HTML and CSS
- **Accessibility**: Built-in utilities for focus states, screen reader text

**Configuration**:
- Custom color palette for financial themes (green for income, red for expenses)
- 8px spacing scale for consistent layout
- Typography plugin for readable text hierarchy
- Forms plugin for beautiful form controls

**Alternatives Considered**:
- **Bootstrap**: More opinionated, harder to customize
- **Custom CSS**: More maintenance, harder to ensure consistency
- **Styled Components**: Requires React, overkill for Rails views

### 6. Chartkick + Groupdate (Data Visualization)

**Decision**: Chartkick with Chart.js backend for reports

**Rationale**:
- **Rails Integration**: Simple Ruby syntax for chart generation
- **Multiple Chart Types**: Pie, bar, line charts for different report needs
- **Responsive**: Charts adapt to screen size
- **Lightweight**: Minimal JavaScript overhead

**Chart Types**:
- **Pie Chart**: Category breakdown for monthly expenses
- **Bar Chart**: Monthly income vs expenses comparison
- **Line Chart**: 6-month spending trends

**Alternatives Considered**:
- **D3.js**: Overkill, too complex for standard charts
- **Google Charts**: External dependency, privacy concerns
- **Apex Charts**: Similar capabilities, Chartkick simpler for Rails

### 7. Docker + Docker Compose (Deployment)

**Decision**: Dockerize application with docker-compose for local development and production

**Rationale**:
- **Consistency**: Same environment across development, testing, production
- **Isolation**: Database and application in separate containers
- **Scalability**: Easy to add Redis, background workers later
- **CI/CD Friendly**: Container images work well with modern deployment platforms

**Container Structure**:
- **web**: Rails application (Puma web server)
- **db**: MySQL 8.0
- **volumes**: Persist database data, uploaded files

**Best Practices**:
- Multi-stage Dockerfile for smaller production images
- Use .dockerignore to exclude unnecessary files
- Named volumes for database persistence
- Health checks for container monitoring

### 8. Faker (Mock Data Generation)

**Decision**: Faker gem for generating realistic seed data

**Rationale**:
- **Realistic Data**: Generates names, emails, dates that look real
- **Large Datasets**: Can generate 100s of transactions for performance testing
- **Variety**: Random categories, amounts, descriptions for diverse test scenarios
- **Locale Support**: Can generate data in different languages/formats

**Seed Data Strategy**:
- 10 demo users with different usage patterns
- 50-200 transactions per user spanning 6 months
- Mix of income and expenses across all categories
- Edge cases (large amounts, zero transactions, same-day duplicates)

## Performance Optimization Strategies

### Database Optimization

1. **Indexing Strategy**:
   - Index `transactions(user_id, date)` for dashboard queries
   - Index `transactions(category_id)` for category filtering
   - Index `users(email)` for authentication lookup

2. **Query Optimization**:
   - Eager loading with `includes` to prevent N+1 queries
   - Use `pluck` instead of full ActiveRecord objects when only needing specific fields
   - Database-level aggregations (SUM, AVG) rather than Ruby loops

3. **Caching**:
   - Fragment caching for monthly reports (expire on new transaction)
   - Action caching for static pages
   - Russian Doll caching for nested partials

### Frontend Optimization

1. **Turbo Frames**: Load parts of page independently without full refresh
2. **Lazy Loading**: Images and charts load as user scrolls
3. **Asset Pipeline**: Minification and compression of CSS/JS
4. **CDN**: Serve static assets from CDN in production

## Security Considerations

1. **Authentication**: Devise with BCrypt password hashing
2. **Authorization**: Ensure users can only access their own transactions
3. **CSRF Protection**: Rails built-in CSRF tokens
4. **SQL Injection**: Parameterized queries via ActiveRecord
5. **XSS Prevention**: ERB auto-escaping
6. **Secure Headers**: Set X-Frame-Options, X-Content-Type-Options
7. **HTTPS Only**: Force SSL in production

## Monitoring & Observability

1. **Logging**: Rails.logger for application logs
2. **Error Tracking**: Future: Sentry or Rollbar integration
3. **Performance Monitoring**: Bullet gem for N+1 query detection
4. **Health Checks**: `/health` endpoint for uptime monitoring

## Development Workflow

1. **Version Control**: Git with feature branches
2. **Code Review**: Pull requests with at least one approval
3. **CI/CD**: GitHub Actions for automated testing
4. **Linting**: RuboCop with Rails style guide
5. **Database Migrations**: Reversible migrations, no data loss

## Conclusions

The selected tech stack (Rails 7.1, MySQL 8.0, Devise, RSpec, TailwindCSS, Docker) provides:
- **Rapid Development**: Rails conventions and generators
- **High Quality**: Comprehensive testing and linting
- **Security**: Industry-standard authentication and data protection
- **Performance**: Optimized database queries and caching strategies
- **Maintainability**: Clear structure with service objects and components
- **Scalability**: Docker containers ready for horizontal scaling

All technology choices align with the project constitution's requirements for code quality, testing, UX consistency, and performance.
