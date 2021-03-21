# frozen_string_literal: true

# auto_register: false

require 'dry/transaction'

require 'pg_export/import'
require 'pg_export/container'
require 'pg_export/lib/pg_export/value_objects/dump_file'

class PgExport
  module Transactions
    class ExportDump
      include Dry::Transaction(container: PgExport::Container)
      include Import['factories.dump_factory', 'adapters.bash_adapter']

      step :prepare_params
      step :build_dump
      step :encrypt_dump, with: 'operations.encrypt_dump'
      step :open_connection, with: 'operations.open_connection'
      step :upload_dump
      step :remove_old_dumps, with: 'operations.remove_old_dumps'
      step :close_connection

      private

      def prepare_params(database_name:)
        database_name = database_name.to_s

        return Failure(message: 'Invalid database name') if database_name.empty?

        Success(database_name: database_name)
      end

      def build_dump(database_name:)
        dump = dump_factory.plain(
          database: database_name,
          file: bash_adapter.pg_dump(ValueObjects::DumpFile.new, database_name)
        )
        Success(dump: dump)
      rescue bash_adapter.class::PgDumpError => e
        Failure(message: 'Unable to dump database: ' + e.to_s)
      end

      def upload_dump(dump:, gateway:)
        gateway.persist(dump.file, dump.name)
        Success(dump: dump, gateway: gateway)
      end

      def close_connection(removed_dumps:, gateway:)
        gateway.close
        Success(gateway: gateway)
      end
    end
  end
end
