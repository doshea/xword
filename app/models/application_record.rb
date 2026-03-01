class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Used by specs (skip_callbacks: true metadata) to disable before/after
  # callbacks during tests that need to create records without side-effects.
  # Defaults to nil/false so it has no effect in production.
  cattr_accessor :skip_callbacks
end
