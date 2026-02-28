# Ruby 3.x fix: ActiveRecord::ConnectionAdapters::PostgreSQL::OID::SpecializedString#initialize
# calls `super(options)` (positional hash) instead of `super(**options)` (keyword args).
# In Ruby 3.x, passing a hash as a positional arg to a kwargs-only method raises ArgumentError.
#
# We must require the file explicitly so the class exists before we prepend.
require 'active_record/connection_adapters/postgresql/oid/specialized_string'

ActiveRecord::ConnectionAdapters::PostgreSQL::OID::SpecializedString.prepend(Module.new do
  def initialize(type, **options)
    @type = type
    super(**options)
  end
end)
