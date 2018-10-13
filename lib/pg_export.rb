# frozen_string_literal: true

require 'pry'
require 'pg_export/container'

class PgExport
  class InitializationError < StandardError; end

  class << self
    def interactive
      boot_main
      new(transaction: PgExport::Container['transactions.import_dump_interactively'])
    end

    def plain
      boot_main
      new(transaction: PgExport::Container['transactions.export_dump'])
    end

    private

    def boot_main
      PgExport::Container.start(:main)
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
