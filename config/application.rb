require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

#Allows me to put custom functions in the custom_funcs.rb file
Dir.glob("./lib/custom_funcs.rb").each { |file| require file }

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Xword
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 7.2.
    # new_framework_defaults_7_2.rb controls the gradual opt-in to 7.2 defaults.
    config.load_defaults 7.2

    # Autoload lib/ (exclude non-Ruby subdirectories)
    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = 'Pacific Time (US & Canada)'
    config.i18n.enforce_available_locales = true

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
