# Personal Finance Tracker

A modern web application for tracking income and expenses with powerful reporting and analytics features.

## Features

- 💰 **Transaction Management**: Track income and expenses with categories, descriptions, and dates
- 📊 **Visual Reports**: Interactive charts showing spending patterns and trends
- 🏷️ **Custom Categories**: Organize transactions with color-coded categories
- 📱 **Responsive Design**: Works seamlessly on desktop, tablet, and mobile
- 🔐 **Secure Authentication**: User accounts with password encryption and session management
- 📈 **Trend Analysis**: View 6-month spending trends and growth rates

## Tech Stack

- **Backend**: Ruby 3.3.0, Rails 7.1.6
- **Database**: MySQL 8.0
- **Frontend**: TailwindCSS, Hotwire (Turbo + Stimulus), Chartkick
- **Testing**: RSpec, FactoryBot, Shoulda-Matchers
- **Deployment**: Docker & Docker Compose

## Quick Start

### Prerequisites

- Docker Desktop 20.10+ and Docker Compose 2.x
- Git 2.30+
- Modern web browser (Chrome 90+, Firefox 88+, Safari 14+)

### Setup with Docker

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd expense-tracker
   ```

2. **Start the application**
   ```bash
   docker-compose up --build
   ```

3. **Setup database** (in another terminal)
   ```bash
   docker-compose exec web bin/rails db:create db:migrate db:seed
   ```

4. **Access the application**
   - Open http://localhost:3000 in your browser
   - Login with demo account:
     - Email: `demo1@example.com` (or demo2, demo3, ... demo10)
     - Password: `Password123!`

### Development Setup

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:create db:migrate db:seed

# Run tests
bundle exec rspec

# Start development server
bin/rails server

# Run TailwindCSS watcher (in separate terminal)
bin/rails tailwindcss:watch
```

## Running Tests

```bash
# Run all tests
docker-compose exec web bundle exec rspec

# Run specific test file
docker-compose exec web bundle exec rspec spec/models/transaction_spec.rb

# Run with documentation format
docker-compose exec web bundle exec rspec --format documentation

# Check test coverage
docker-compose exec web bundle exec rspec
# View coverage/index.html
```

## Project Structure

```
expense-tracker/
├── app/
│   ├── controllers/      # HTTP request handlers
│   ├── models/           # Database models
│   ├── services/         # Business logic layer
│   │   └── reports/      # Report generation services
│   ├── helpers/          # View helpers
│   ├── views/            # ERB templates
│   └── javascript/       # Stimulus controllers
├── config/               # Application configuration
├── db/
│   ├── migrate/          # Database migrations
│   └── seeds.rb          # Seed data
├── spec/                 # RSpec tests
└── docker-compose.yml    # Docker configuration
```

## Key Features

### Transactions
- Add, edit, delete transactions
- Filter by date range, type (income/expense), and category
- Pagination support
- Real-time form validation

### Categories
- Create custom categories with colors
- Separate income and expense categories
- Default categories provided
- Deletion protection for categories in use

### Reports & Analytics
- Monthly financial summary
- Custom date range reports
- 6-month trend analysis with line charts
- Category-wise spending breakdown
- Savings rate calculation
- Growth rate indicators

## Configuration

### Environment Variables

Create a `.env` file (or use `.env.example`):

```env
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=expense_tracker_development
MYSQL_USER=expense_tracker
MYSQL_PASSWORD=password

DATABASE_HOST=db
DATABASE_PORT=3306
```

### Database Configuration

The application uses MySQL 8.0. Configuration is in `config/database.yml`.

## API Endpoints

### Authentication
- `POST /users/sign_in` - Login
- `DELETE /users/sign_out` - Logout
- `POST /users` - Sign up

### Transactions
- `GET /transactions` - List transactions (with filters)
- `GET /transactions/:id` - Show transaction
- `POST /transactions` - Create transaction
- `PATCH /transactions/:id` - Update transaction
- `DELETE /transactions/:id` - Delete transaction

### Categories
- `GET /categories` - List all categories
- `POST /categories` - Create category
- `PATCH /categories/:id` - Update category
- `DELETE /categories/:id` - Delete category

### Reports
- `GET /reports` - Current month dashboard
- `GET /reports/monthly` - Custom date range report
- `GET /reports/trends` - Multi-month trend analysis

## Testing

The application has comprehensive test coverage:

- **Model specs**: Validations, associations, scopes
- **Service specs**: Business logic and calculations
- **Controller specs**: HTTP interactions (known issues with authentication)
- **Feature specs**: End-to-end user flows (requires browser driver)

Current coverage: 80%+ on tested components

## Troubleshooting

### Container Issues

```bash
# Restart containers
docker-compose restart

# Rebuild from scratch
docker-compose down -v
docker-compose up --build

# View logs
docker-compose logs web
docker-compose logs db
```

### Database Issues

```bash
# Reset database
docker-compose exec web bin/rails db:drop db:create db:migrate db:seed

# Check migrations
docker-compose exec web bin/rails db:migrate:status
```

### Permission Issues

```bash
# Fix file permissions (Linux/Mac)
docker-compose exec -u 0 -T web chown -R $(id -u):$(id -g) /rails
```

## Contributing

1. Create a feature branch
2. Write tests for new features
3. Ensure all tests pass
4. Run RuboCop for code quality
5. Submit a pull request

## License

[Your License Here]

## Support

For issues and questions, please open a GitHub issue.
