source 'https://rubygems.org'

gem 'rails', '3.2.5'

gem 'i18n_generators'

# Model
#gem 'sqlite3', group: :development
gem 'pg'

# View
gem 'slim-rails'
gem 'jquery-rails', "2.0.1"
gem 'spinjs-rails'
gem 'active_decorator'

# Assets
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

# Heroku
group :production do
  gem 'pg'
  gem 'therubyracer-heroku', '0.8.1.pre3'
end

# Tools
group :development do
  gem 'pry-rails'
  gem "rails-erd"
end

group :development, :test do
  gem 'awesome_print'
  gem 'tapp'
end

# Testing
group :test do
  gem 'test-unit', '>= 2'
  gem 'shoulda-context'
  gem 'spork-testunit'
end
