source 'https://rubygems.org'

gem 'rails', '~> 4.2.6'

# Удобная админка для управления любыми сущностями
gem 'rails_admin'

gem 'devise', '~> 4.1.1'
gem 'devise-i18n'

gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'
gem 'twitter-bootstrap-rails'
gem 'font-awesome-rails'
gem 'russian'

group :development, :test do
  gem 'sqlite3', '~> 1.3.13'
  gem 'pry'
  gem 'rspec-rails', '~> 3.4'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
  gem 'ffaker'
end

group :test do
  # Гем, который использует rspec, чтобы смотреть наш сайт
  gem 'capybara'

  # Гем, который позволяет смотреть, что видит capybara
  gem 'launchy'

  gem 'database_cleaner-active_record'
end

group :production do
  gem 'pg', '~> 0.20.0'
end
