require 'simplecov'

#using the 'rails' profile prevents files outside /app from being checked
SimpleCov.start 'rails'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'launchy'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  #Clean unless tagged with :dirty_inside
  #For more info on around hooks, check out http://spin.atomicobject.com/2013/03/24/using-the-rspec-around-hook/
  config.around(:each) do |example|
    if (example.metadata[:dirty_inside])
      example.run
    else
      DatabaseCleaner.cleaning do
        example.run
      end
    end
  end

  config.before(:all, dirty_inside: true) do
    DatabaseCleaner.start
  end

  config.after(:all, dirty_inside: true) do
    DatabaseCleaner.clean
  end

  #allows me to skip callbacks when I want to using the skip_callbacks metadata tag
  config.before(:all, skip_callbacks: true) do
    ActiveRecord::Base.skip_callbacks = true
  end
  config.after(:all, skip_callbacks: true) do
    ActiveRecord::Base.skip_callbacks = nil
  end

  # config.color_enabled = true
  config.tty = true
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end