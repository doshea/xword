# Load the Rails application.
require_relative "application"

class ActiveRecord::Base
  # skip_callbacks: used by spec_helper to disable before/after callbacks in tests
  cattr_accessor :skip_callbacks
end

# Initialize the Rails application.
Rails.application.initialize!
