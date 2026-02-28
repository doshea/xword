# Ruby 3.x compatibility: patch ActiveModel::Type::Value#initialize to accept
# a positional hash (the Rails 5.1.4 calling convention) and forward it as
# keyword args.  This fixes Integer, Decimal, Float, String, and every other
# subclass in one shot.
require 'active_model/type/value'

ActiveModel::Type::Value.prepend(Module.new do
  def initialize(*args, precision: nil, limit: nil, scale: nil, **rest)
    if args.length == 1 && args.first.is_a?(Hash)
      opts = args.first
      super(precision: opts[:precision], limit: opts[:limit], scale: opts[:scale])
    else
      super(precision: precision, limit: limit, scale: scale)
    end
  end
end)

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
