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
        'ui.interactive.input',
        'adapters.bash_adapter',
        'repositories.gateway_dump_repository',
        'repositories.gateway_dump_file_repository'
      ]

      step :open_connection, with: 'operations.open_connection'
      step :fetch_dumps
      step :select_dump
      step :download_dump
      step :close_connection
      step :decrypt_dump, with: 'operations.decrypt_dump'
      step :select_database
      step :restore

      private

      def fetch_dumps(database_name:, gateway:)
        dumps = gateway_dump_repository.all(database_name: database_name, gateway: gateway)
        return Failure(message: 'No dumps') if dumps.none?

        Success(gateway: gateway, dumps: dumps)
      end

      def select_dump(dumps:, gateway:)
        dump = input.select_dump(dumps)
        Success(dump: dump, gateway: gateway)
      end

      def download_dump(dump:, gateway:)
        dump.file = gateway_dump_file_repository.by_name(name: dump.name, gateway: gateway)
        Success(dump: dump, gateway: gateway)
      end

      def close_connection(dump:, gateway:)
        Thread.new { gateway.close }
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
