# frozen_string_literal: true

source 'https://rubygems.org'

gem 'importmap-rails'
gem 'propshaft'
gem 'puma', '>= 5.0'
gem 'rails', '~> 8.1'
gem 'sqlite3', '~> 2.8'
gem 'stimulus-rails'
gem 'turbo-rails'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem 'solid_cable', '~> 3.0'
gem 'solid_cache', '~> 1.0'
gem 'solid_queue', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem 'kamal', '~> 2.8', require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  gem 'rspec-rails', '~> 8.0'
  gem 'rubocop-capybara'
  gem 'rubocop-rails'
  gem 'rubocop-rspec_rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  gem 'i18n-tasks', '~> 1.1.1'
  gem 'letter_opener'
  gem 'rails-erd', '~> 1.7'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'pundit-matchers', '~> 4.0'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end

gem 'tailwindcss-rails', '= 3.1.0'
gem 'tailwindcss-ruby', '= 3.4.17'

gem 'passwordless', '~> 1.8'

gem 'pundit', '~> 2.5'

gem 'rails-i18n', '~> 8.1.0'

gem 'icalendar', '~> 2.12'

gem 'down', '~> 5.4'

gem 'arask', '~> 1.2'

gem 'faker', '~> 3.5'

gem 'aws-sdk-s3', '~> 1.205', require: false

gem 'image_processing', '~> 1.13'

gem 'chartkick', '~> 5.2'

gem 'tabler_icons', '~> 0.1.1'

gem 'spreadsheet_architect', '~> 5.1'

gem 'litestream', '~> 0.14.0'

gem 'positioning', '~> 0.4.7'
