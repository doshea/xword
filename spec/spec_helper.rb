require 'simplecov'
require 'benchmark'

#using the 'rails' profile prevents files outside /app from being checked
SimpleCov.start 'rails'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/cuprite'
require 'launchy'

Capybara.default_selector = :css
Capybara.ignore_hidden_elements = true #will not find hidden elements
Capybara.default_max_wait_time = 5

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app, headless: true, browser_options: { 'no-sandbox': nil })
end
Capybara.javascript_driver = :cuprite

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |c|
  c.expect_with(:rspec) { |ec| ec.syntax = :expect }
  c.mock_with(:rspec)   { |mc| mc.syntax = :expect }
  # c.fail_fast = true
  c.infer_spec_type_from_file_location!
  c.include FactoryBot::Syntax::Methods
  c.include AuthHelpers, type: :controller
  c.include RequestAuthHelpers, type: :request

  c.before(:suite) do
    retries = 0
    begin
      DatabaseCleaner.clean_with(:truncation)
    rescue ActiveRecord::Deadlocked => e
      retries += 1
      raise if retries > 3
      ActiveRecord::Base.connection_pool.disconnect!
      sleep 1
      retry
    end
  end

  c.around(:each) do |example|
    if example.metadata[:dirty_inside]
      example.run
    elsif example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.cleaning { example.run }
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.cleaning { example.run }
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
    ApplicationRecord.skip_callbacks = true
  end
  c.after(:all, skip_callbacks: true) do
    ApplicationRecord.skip_callbacks = nil
  end

  # c.color_enabled = true
  c.tty = true
  c.use_transactional_fixtures = false
  c.order = "random"
end