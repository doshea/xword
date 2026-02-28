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

# Ruby 3.x fix: create_table_definition(*args) swallows trailing keyword args
# (e.g. `comment: comment`) into the *args array as a plain Hash.  When that
# array is then splatted into TableDefinition.new(*args) it arrives as an extra
# positional argument, causing "given 5, expected 1..4".
#
# Fix both the abstract adapter and the PostgreSQL adapter so keyword args are
# captured separately and forwarded with **.
require 'active_record/connection_adapters/abstract/schema_statements'
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements
      private

      def create_table_definition(*args, **kwargs)
        TableDefinition.new(*args, **kwargs)
      end
    end

    class PostgreSQLAdapter
      private

      def create_table_definition(*args, **kwargs)
        PostgreSQL::TableDefinition.new(*args, **kwargs)
      end
    end

    # Ruby 3.x fix: TableDefinition#new_column_definition(name, type, **options)
    # is called from #column and AlterTable#add_column with a positional Hash.
    # In Ruby 3.x that raises "given 3, expected 2".  Accept both conventions.
    class TableDefinition
      def new_column_definition(name, type, options_hash = {}, **kwargs)
        options = options_hash.merge(kwargs)
        type = aliased_types(type.to_s, type)
        options[:primary_key] ||= type == :primary_key
        options[:null] = false if options[:primary_key]
        create_column_definition(name, type, options)
      end
    end
  end
end

# Ruby 3.x fix: SchemaCreation#visit_ColumnDefinition calls type_to_sql(type, options)
# with a positional Hash.  type_to_sql on both AbstractAdapter and PostgreSQLAdapter
# declares only keyword args (limit:, precision:, scale:, …).  The call goes through
# ActiveSupport's `delegate` macro which generates (*args, &block) — no **kwargs — so
# the hash can never be splatted cleanly.  Patch both type_to_sql methods to also
# accept a single positional Hash and extract the known keys.
ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(Module.new do
  def type_to_sql(type, options_or_limit = nil, limit: nil, precision: nil, scale: nil, **rest)
    if options_or_limit.is_a?(Hash)
      super(type, limit: options_or_limit[:limit],
                  precision: options_or_limit[:precision],
                  scale: options_or_limit[:scale])
    else
      super(type, limit: options_or_limit || limit, precision: precision, scale: scale)
    end
  end
end)

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(Module.new do
  def type_to_sql(type, options_or_limit = nil, limit: nil, precision: nil, scale: nil, array: nil, **rest)
    if options_or_limit.is_a?(Hash)
      super(type, limit: options_or_limit[:limit],
                  precision: options_or_limit[:precision],
                  scale: options_or_limit[:scale],
                  array: options_or_limit[:array])
    else
      super(type, limit: options_or_limit || limit, precision: precision, scale: scale, array: array)
    end
  end
end)
