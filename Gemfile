source 'https://rubygems.org'

#yard_path = File.expand_path("../yard", File.dirname(__FILE__))
#gem 'yard', git: "file://#{yard_path}", branch: "i18n"
gem 'yard', git: 'git://github.com/yhara/yard.git', branch: "i18n"
gem 'fast_gettext'

gem 'rails', '3.2.1'

gem 'i18n_generators'

# Model
#gem 'sqlite3', group: :development
gem 'pg'

# View
gem 'slim-rails'
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

gem 'jquery-rails'

group :development do
  gem 'pry-rails'
  gem 'awesome_print'
  gem "rails-erd"
end

