require_relative 'boot'

# require 'rails/all'
# Pick the frameworks you want:
require "active_record/railtie"

# Ruby 3.x fix: Rails 5.1.4's `delegate :add_modifier` doesn't forward keyword
# arguments in Ruby 3.x, passing them as a 3rd positional hash instead.
# Override the class method to properly handle kwargs before the PostgreSQL
# adapter is loaded and calls add_modifier with `adapter: :postgresql`.
ActiveRecord::Type.define_singleton_method(:add_modifier) do |options, klass, **kwargs|
  registry.add_modifier(options, klass, **kwargs)
end

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "action_cable" #NECESSARY FOR ACTION CABLE
require "action_cable/engine"
# require "rails/test_unit/railtie"

#Allows me to put custom functions in the custom_funcs.rb file
Dir.glob("./lib/custom_funcs.rb").each { |file| require file }

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Xword
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.time_zone = 'Pacific Time (US & Canada)'
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true
  end
end
