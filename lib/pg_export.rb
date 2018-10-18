# frozen_string_literal: true

require 'pry'
require 'pg_export/container'

class PgExport
  class InitializationError < StandardError; end

  class << self
    def interactive
      PgExport::Container.start(:interactive)
      new(transaction: PgExport::Container['transactions.import_dump_interactively'])
    end

    def plain
      PgExport::Container.start(:plain)
      new(transaction: PgExport::Container['transactions.export_dump'])
    end
  end

  def initialize(transaction:)
    @transaction = transaction
  end

  def call(database_name, &block)
    transaction.call(database_name: database_name, &block)
  end

  private

  attr_reader :transaction
end
