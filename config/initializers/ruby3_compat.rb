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

      # Ruby 3.x fix: t.string :col, options_hash passes the Hash positionally.
      # The generated methods use (*args, **options) so in Ruby 3.x the hash lands
      # in *args as a second "column name" instead of as options.
      # Redefine each generated column-type method to detect and extract a trailing
      # positional Hash from args and treat it as the options hash.
      # Ruby 3.x fix: references(*args, **options) calls
      # ReferenceDefinition.new(ref_name, options) with a positional hash.
      # ReferenceDefinition#initialize only accepts kwargs → given 2, expected 1.
      def references(*args, **options)
        args.each do |ref_name|
          ReferenceDefinition.new(ref_name, **options).add_to(self)
        end
      end
      alias :belongs_to :references

      [
        :bigint, :binary, :boolean, :date, :datetime, :decimal, :float,
        :integer, :primary_key, :string, :text, :time, :timestamp, :virtual,
      ].each do |col_type|
        define_method(col_type) do |*args, **options|
          if args.last.is_a?(Hash)
            options = args.pop.merge(options)
          end
          args.each { |name| column(name, col_type, options) }
        end
      end
    end
  end
end

# Ruby 3.x fix: RealTransaction/SavepointTransaction#initialize take (*args) so
# the run_commit_callbacks: keyword from begin_transaction lands in *args as a Hash.
# super then passes that Hash as a 3rd positional arg to Transaction#initialize
# which declares (connection, options, run_commit_callbacks: false) — only 2 positional.
require 'active_record/connection_adapters/abstract/transaction'

module ActiveRecord
  module ConnectionAdapters
    class Transaction
      def initialize(connection, options, extra = nil, run_commit_callbacks: false)
        if extra.is_a?(Hash)
          run_commit_callbacks = extra.fetch(:run_commit_callbacks, run_commit_callbacks)
        end
        @connection            = connection
        @state                 = TransactionState.new
        @records               = []
        @joinable              = options.fetch(:joinable, true)
        @run_commit_callbacks  = run_commit_callbacks
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
# Ruby 3.x fix: migration method_missing calls connection.send(:create_table, name, opts_hash)
# with a positional Hash.  compatibility.rb also calls super(table_name, options).
# create_table(table_name, comment: nil, **options) only accepts kwargs → given 2, expected 1.
ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(Module.new do
  def create_table(table_name, opts_hash = nil, comment: nil, **options, &block)
    if opts_hash.is_a?(Hash)
      merged = opts_hash.merge(options)
      extracted_comment = merged.delete(:comment)
      super(table_name, comment: extracted_comment || comment, **merged, &block)
    else
      super(table_name, comment: comment, **options, &block)
    end
  end
end)

# Ruby 3.x fix: ActiveRecord::Base.transaction(options = {}) passes a positional
# Hash to connection.transaction(requires_new:, isolation:, joinable:) which only
# accepts keyword args → ArgumentError: given 1, expected 0.
ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(Module.new do
  def transaction(opts_or_kw = nil, requires_new: nil, isolation: nil, joinable: true, **rest, &block)
    if opts_or_kw.is_a?(Hash)
      super(requires_new: opts_or_kw.fetch(:requires_new, requires_new),
            isolation:    opts_or_kw.fetch(:isolation,    isolation),
            joinable:     opts_or_kw.fetch(:joinable,     joinable),
            &block)
    else
      super(requires_new: requires_new, isolation: isolation, joinable: joinable, &block)
    end
  end
end)

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
