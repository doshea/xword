source 'https://rubygems.org'

ruby '2.2.1'
gem 'rails'
gem 'coffee-rails'
gem 'json'

gem 'httparty'

gem 'multi_json'

gem 'pusher'

# gem 'protected_attributes' #Until I fix things to properly use Rails 4. UPGRADE THIS PLEASE.

gem 'pg'
gem 'haml'
gem 'bcrypt-ruby'

# asset gems
gem 'sass-rails'
gem 'uglifier'

# AWS image upload gems
gem 'carrierwave'
gem 'fog'
gem 'rmagick'
gem 'remotipart'
gem 'unf'

#Slighty Fuzzy search. Probably needs to be replaced with Solr.
gem 'pg_search'

gem 'nilify_blanks' #TODO use this

#JS gems
gem 'jquery-rails'
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'
gem 'will_paginate', '~> 3.0'

#Moved out of development-only so that Heroku can use it
gem 'pry-rails'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  #testing gems
  gem 'annotate'
  gem 'rainbow'

  gem 'quiet_assets'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails', '2.14.2' #TODO upgrade to Rspec 3
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'guard-rspec'
  gem 'faker'
  gem 'simplecov','~> 0.7.1' , :require => false
end

group :development do
  #causes problem in conjunction with rspec test
  gem 'better_errors' #do not put this in production or everyone will be able to mess around with variables
  gem 'spring'
end

group :production do
  gem 'rails_12factor'
end

group :production, :development do
    gem 'pry-byebug'
    gem 'pry-stack_explorer'
end