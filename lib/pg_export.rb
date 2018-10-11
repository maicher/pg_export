# frozen_string_literal: true

require 'pg_export/transactions/export_dump'
require 'pg_export/transactions/import_dump_interactively'
require 'pg_export/configuration'
require 'pry'

class PgExport
  class InitializationError < StandardError; end

  def initialize
    config = Configuration.new(
      dump_encryption_key: ENV['DUMP_ENCRYPTION_KEY'],
      ftp_host: ENV['BACKUP_FTP_HOST'],
      ftp_user: ENV['BACKUP_FTP_USER'],
      ftp_password: ENV['BACKUP_FTP_PASSWORD'],
      logger_format: ENV['LOGGER_FORMAT'],
      interactive: ENV['INTERACTIVE']
    )

    @transaction =
      if config.interactive
        Transactions::ImportDumpInteractively.new
      else
        Transactions::ExportDump.new
      end

    transaction.container = BootContainer.call(config.to_h)
  rescue Dry::Struct::Error => e
    raise InitializationError, e
  end

  def call(database_name, keep_dumps, &block)
    transaction.call(database_name: database_name, keep_dumps: keep_dumps, &block)
  end

  private

  attr_reader :transaction
end
