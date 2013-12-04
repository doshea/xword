source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '4.0.2'
gem 'coffee-rails'
gem 'json'

gem 'httparty'

gem 'multi_json', '1.7.8' #Necessary because 1.7.9 breaks the adapter specification  http://stackoverflow.com/questions/18213286/did-not-recognize-your-adapter-specification-turbolinks-related-error-in-rails/18239501?noredirect=1#comment27522141_18239501

gem 'pusher'

gem 'protected_attributes' #Until I fix things to properly use Rails 4. UPGRADE THIS PLEASE.

gem 'pg'
gem 'haml'
gem 'bcrypt-ruby'

#asset gems
gem 'sass-rails', '~> 4.0.1'
gem 'uglifier', '>= 1.3.0'

gem 'foundation-icons-sass-rails'

# AWS image upload gems
gem 'carrierwave'
gem 'fog'
gem 'rmagick'
gem 'remotipart'
gem 'unf'

#Slighty Fuzzy search. Probably needs to be replaced with Solr.
gem 'pg_search'

#Growl-like browser notifications
gem 'gritter'

#JS gems
gem 'jquery-rails'
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

#Moved out of development-only so that Heroku can use it
gem 'pry-rails'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  #testing gems
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
  gem 'better_errors' #do not put this in production or everyone will be able to mess around with variables
end

group :production do
  gem 'rails_12factor'
end

group :production, :development do
    gem 'pry-debugger'
    gem 'pry-stack_explorer'
end