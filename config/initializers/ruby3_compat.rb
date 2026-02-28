# Ruby 3.x fix: ActiveRecord::ConnectionAdapters::PostgreSQL::OID::SpecializedString#initialize
# calls `super(options)` (positional hash) instead of `super(**options)` (keyword args).
# In Ruby 3.x, passing a hash as a positional arg to a kwargs-only method raises ArgumentError.
#
# Reopen and redefine initialize so super(**options) goes to Value#initialize correctly.
require 'active_record/connection_adapters/postgresql/oid/specialized_string'

module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module OID
        class SpecializedString
          def initialize(type, **options)
            @type = type
            super(**options)
          end
        end
      end
    end
  end
end
