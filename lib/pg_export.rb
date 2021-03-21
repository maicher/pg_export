# frozen_string_literal: true

require 'pg_export/container'
require 'pg_export/import'

class PgExport
  class InitializationError < StandardError; end

  include Import['transaction']

  def self.boot
    PgExport::Container.start(:main)
    new
  end

  def call(database_name, &block)
    transaction.call(database_name: database_name, &block)
  end

  private

  attr_reader :transaction
end
