# frozen_string_literal: true

require 'pg_export/transactions/export_dump'
require 'pg_export/transactions/import_dump_interactively'
require 'pg_export/configuration'
require 'pry'

class PgExport
  def initialize(**args)
    config = Configuration.new(**args)

    @transaction =
      if config.interactive
        Transactions::ImportDumpInteractively.new
      else
        Transactions::ExportDump.new
      end

    transaction.container = BootContainer.call(config.to_h)
  rescue Dry::Struct::Error => e
    raise ArgumentError, e
  end

  def call(database_name, keep_dumps)
    transaction.call(database_name: database_name, keep_dumps: keep_dumps)
  end

  private

  attr_reader :transaction
end
