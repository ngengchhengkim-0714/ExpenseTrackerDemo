# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim

# Rails app lives here
WORKDIR /rails

# Install packages needed to build gems and run the application
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    default-libmysqlclient-dev \
    git \
    libvips \
    pkg-config \
    curl \
    default-mysql-client \
    nodejs \
    npm \
    wget \
    gnupg && \
    # Install Chrome for system tests
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Ensure builds directory exists and build Tailwind CSS
RUN mkdir -p app/assets/builds && \
    bin/rails tailwindcss:build

# Precompile assets for production
RUN SECRET_KEY_BASE=dummy bin/rails assets:precompile

# Create directories for Rails
RUN mkdir -p tmp/pids log storage

# Expose port 3000
EXPOSE 3000

# Set entrypoint for database migrations
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
