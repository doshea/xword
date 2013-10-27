source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '4.0.0'
gem 'coffee-rails'
gem 'json'

gem 'httparty'

gem 'multi_json', '1.7.8' #Necessary because 1.7.9 breaks the adapter specification  http://stackoverflow.com/questions/18213286/did-not-recognize-your-adapter-specification-turbolinks-related-error-in-rails/18239501?noredirect=1#comment27522141_18239501

gem 'pusher'

gem 'protected_attributes'

gem 'pg'
gem 'haml'
gem 'bcrypt-ruby', '3.0.0'

#asset gems
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'

gem 'foundation-icons-sass-rails'

# AWS image upload gems
gem 'carrierwave'
gem 'fog'
gem 'rmagick'
gem 'remotipart'

#Slighty Fuzzy search. Probably needs to be replaced with Solr.
gem 'pg_search'

#Growl-like browser notifications
gem 'gritter'

#JS gems
gem 'jquery-rails'
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  #testing gems
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

group :production do
  gem 'rails_12factor'
end