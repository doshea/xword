source 'https://rubygems.org'

gem 'rails', '~> 7.2.0'
gem 'json'

gem 'httparty'

gem 'multi_json'

gem 'pusher'

#required server for ActionCable
gem 'puma', '~> 5.0'
gem 'redis'

gem 'pg', '~> 1.2'
gem 'haml', '~> 5.2'
gem 'bcrypt'

gem 'active_record_union'

# asset gems
gem 'sassc-rails'
gem 'sprockets', '~> 4.2'
gem 'terser'                  # replaces uglifier

# AWS image upload gems
gem 'carrierwave'
gem 'fog-aws'
gem 'rmagick'
gem 'remotipart'
gem 'unf'

#Slighty Fuzzy search. Probably needs to be replaced with Solr.
gem 'pg_search'

gem 'nilify_blanks'

#JS gems
gem 'jquery-rails'
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.12'
gem 'will_paginate', '~> 3.0'

#Moved out of development-only so that Heroku can use it
gem 'pry-rails'

group :development, :test do
  #testing gems
  gem 'annotate', '~> 3.2'
  gem 'rainbow'

  gem 'binding_of_caller'
  gem 'meta_request', '~> 0.8'
end

group :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 4.0'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'capybara', '~> 3.0'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'guard-rspec'
  gem 'faker'
  gem 'simplecov', '~> 0.22', require: false
end

group :development do
  #causes problem in conjunction with rspec test
  gem 'better_errors' #do not put this in production or everyone will be able to mess around with variables
  # gem 'spring'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
end

group :production do
  # gem 'rails_12factor'
end

ruby '3.1.6'
