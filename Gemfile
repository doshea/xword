source 'https://rubygems.org'

gem 'rails'

gem 'newrelic_rpm'

gem 'nokogiri'
gem 'pg'
gem 'jquery-rails'
gem 'haml'
gem 'bcrypt-ruby'
gem 'json'

# AWS image upload gems
gem 'carrierwave'
gem 'fog'
gem 'rmagick'
gem 'remotipart'

#Slighty Fuzzy search. Probably needs to be replaced with Solr.
gem 'pg_search'

#Growl-like browser notifications
gem 'gritter'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'foundation-icons-sass-rails'
end

group :development, :test do
  #testing gems
  gem 'rb-fsevent'

  gem 'pry-rails'
  gem 'pry-debugger'
  gem 'pry-stack_explorer'

  gem 'annotate'

  gem 'quiet_assets'
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
end

group :development do
  #causes problem in conjunction with rspec test
  gem 'better_errors'
end