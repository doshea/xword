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

    # Ruby 3.x fix: AbstractAdapter::SchemaCreation#visit_ColumnDefinition calls
    # type_to_sql(o.type, o.options) with a positional Hash, but type_to_sql
    # accepts only keyword args in Rails 5.1.4.  Splat the options hash.
    class AbstractAdapter
      class SchemaCreation
        private

        def visit_ColumnDefinition(o)
          o.sql_type = type_to_sql(o.type, **(o.options || {}))
          column_sql = "#{quote_column_name(o.name)} #{o.sql_type}"
          add_column_options!(column_sql, column_options(o)) unless o.type == :primary_key
          column_sql
        end
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
