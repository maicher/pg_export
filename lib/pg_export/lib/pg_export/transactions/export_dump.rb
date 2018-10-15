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
      include Import['factories.dump_factory', 'adapters.bash_adapter', 'ftp_adapter']

      step :prepare_params
      step :build_dump
      step :encrypt_dump, with: 'operations.encrypt_dump'
      step :open_ftp_connection
      step :upload_dump_to_ftp
      step :remove_old_dumps_from_ftp, with: 'operations.remove_old_dumps_from_ftp'
      step :close_ftp_connection

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
        Failure(message: 'Error dumping database: ' + e.to_s)
      end

      def open_ftp_connection(dump:)
        ftp_adapter.open_ftp
        Success(dump: dump, ftp_adapter: ftp_adapter)
      end

      def upload_dump_to_ftp(dump:, ftp_adapter:)
        ftp_adapter.persist(dump.file, dump.name)
        Success(dump: dump, ftp_adapter: ftp_adapter)
      end

      def close_ftp_connection(removed_dumps:, ftp_adapter:)
        ftp_adapter.close_ftp
        Success(removed_dumps: removed_dumps, ftp_adapter: ftp_adapter)
      end
    end
  end
end
