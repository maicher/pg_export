# frozen_string_literal: true

# auto_register: false

require 'dry/transaction'

require 'pg_export/import'
require 'pg_export/container'

class PgExport
  module Transactions
    class ImportDumpInteractively
      include Dry::Transaction(container: PgExport::Container)
      include Import[
        'adapters.bash_adapter',
        'repositories.ftp_dump_repository',
        'repositories.ftp_dump_file_repository',
        'ui.interactive.input'
      ]

      step :open_ftp_connection, with: 'operations.open_ftp_connection'
      step :fetch_dumps_from_ftp
      step :select_dump
      step :download_dump_from_ftp
      step :close_ftp_connection
      step :decrypt_dump, with: 'operations.decrypt_dump'
      step :select_database
      step :restore

      private

      def fetch_dumps_from_ftp(database_name:, ftp_adapter:)
        dumps = ftp_dump_repository.all(database_name: database_name, ftp_adapter: ftp_adapter)
        Success(ftp_adapter: ftp_adapter, dumps: dumps)
      end

      def select_dump(dumps:, ftp_adapter:)
        dump = input.select_dump(dumps)
        Success(dump: dump, ftp_adapter: ftp_adapter)
      end

      def download_dump_from_ftp(dump:, ftp_adapter:)
        dump.file = ftp_dump_file_repository.by_name(name: dump.name, ftp_adapter: ftp_adapter)
        Success(dump: dump, ftp_adapter: ftp_adapter)
      end

      def close_ftp_connection(dump:, ftp_adapter:)
        Thread.new { ftp_adapter.close_ftp }
        Success(dump: dump)
      end

      def select_database(dump:)
        name = input.enter_database_name(dump.database)
        Success(dump: dump, database: name)
      end

      def restore(dump:, database:)
        bash_adapter.pg_restore(dump.file, database)
        Success({})
      rescue bash_adapter.class::PgRestoreError => e
        Failure(message: e.to_s)
      end
    end
  end
end
