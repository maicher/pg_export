require 'pg_export/transactions/export_dump'
require 'pg_export/transactions/import_dump_interactively'
require 'pg_export/configuration'
require 'pry'

class PgExport
  def initialize(**args)
    config = Configuration.new(**args)

    @transaction =
      if config.interactive
        Transactions::ImportDumpInteractively.new(args)
      else
        Transactions::ExportDump.new(args)
      end
  rescue Dry::Struct::Error => e
    raise ArgumentError, e
  end

  def call(database_name, keep_dumps)
    transaction.call(database_name, keep_dumps)
  end

  private

  attr_reader :transaction
end
