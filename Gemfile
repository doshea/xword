source 'https://rubygems.org'

gem 'rails'
gem 'coffee-rails'
gem 'json'

gem 'httparty'

gem 'multi_json'

gem 'pusher'

gem 'record_tag_helper' #so that content_tag_for works

#TODO TEMPORARY FIX --> http://stackoverflow.com/questions/31793791/push-to-heroku-fails-could-not-find-net-ssh-2-10-0-in-any-of-the-sources-faile
# gem 'net-ssh', '!= 2.10.0'

#required server for ActionCable
gem 'puma'
gem 'redis'

gem 'pg', '~> 0.20'
gem 'haml'
gem 'bcrypt-ruby'

gem 'active_record_union'

# asset gems
gem 'sass-rails'


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
gem 'jbuilder'
gem 'will_paginate', '~> 3.0'

#Moved out of development-only so that Heroku can use it
gem 'pry-rails'
gem 'uglifier' #used to only be dev and test but was causing issues in production...

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  #testing gems
  gem 'annotate'
  gem 'rainbow'

  gem 'binding_of_caller'
  gem 'meta_request'
end

group :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
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
  # gem 'spring'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
end

group :production do
  # gem 'rails_12factor'
end