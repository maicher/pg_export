# frozen_string_literal: true

require 'pg_export/transactions/export_dump'
require 'pg_export/transactions/import_dump_interactively'
require 'pg_export/configuration'
require 'pry'

class PgExport
  class << self
    def interactive
      new(transaction: Transactions::ImportDumpInteractively.new)
    end

    def plain
      new(transaction: Transactions::ExportDump.new)
    end
  end

  def initialize(transaction:)
    @transaction = transaction
  end

  def call(database_name, keep_dumps, &block)
    transaction.call(database_name: database_name, keep_dumps: keep_dumps, &block)
  end

  private

  attr_reader :transaction
end
