require 'simplecov'
require 'benchmark'

#using the 'rails' profile prevents files outside /app from being checked
SimpleCov.start 'rails'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/its'
require 'capybara/rspec'
require 'launchy'

Capybara.default_selector = :css
Capybara.ignore_hidden_elements = true #will not find hidden elements

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |c|
  # Suppress deprecation warnings: suite uses the old :should syntax throughout.
  # Re-evaluate when migrating to expect() syntax.
  c.expect_with(:rspec) { |ec| ec.syntax = [:should, :expect] }
  c.mock_with(:rspec)   { |mc| mc.syntax = [:should, :expect] }
  # c.fail_fast = true
  c.infer_spec_type_from_file_location!
  c.include FactoryBot::Syntax::Methods

  c.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  #Clean unless tagged with :dirty_inside
  #For more info on around hooks, check out http://spin.atomicobject.com/2013/03/24/using-the-rspec-around-hook/
  c.around(:each) do |example|
    if (example.metadata[:dirty_inside])
      example.run
    else
      DatabaseCleaner.cleaning do
        example.run
      end
    end
  end

  c.before(:all, dirty_inside: true) do
    DatabaseCleaner.start
  end

  c.after(:all, dirty_inside: true) do
    DatabaseCleaner.clean
  end

  #allows me to skip callbacks when I want to using the skip_callbacks metadata tag
  c.before(:all, skip_callbacks: true) do
    ActiveRecord::Base.skip_callbacks = true
  end
  c.after(:all, skip_callbacks: true) do
    ActiveRecord::Base.skip_callbacks = nil
  end

  # c.color_enabled = true
  c.tty = true
  c.use_transactional_fixtures = false
  c.order = "random"
end