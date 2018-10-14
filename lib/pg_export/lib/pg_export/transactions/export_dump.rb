# frozen_string_literal: true

require 'dry/transaction'

require 'pg_export/import'
require 'pg_export/container'

class PgExport
  module Transactions
    class ExportDump
      include Dry::Transaction(container: PgExport::Container)
      include Import['factories.dump_factory']

      step :prepare_params
      step :build_dump
      step :encrypt_dump,              with: 'operations.encrypt_dump'
      step :upload_dump_to_ftp,        with: 'operations.upload_dump_to_ftp'
      step :remove_old_dumps_from_ftp, with: 'operations.remove_old_dumps_from_ftp'

      private

      def prepare_params(database_name:)
        database_name = database_name.to_s

        return Failure(message: 'Invalid database name') if database_name.empty?

        Success(database_name: database_name)
      end

      def build_dump(database_name:)
        dump = dump_factory.from_database(database_name)

        Success(dump: dump, database_name: database_name)
      rescue Adapters::BashAdapter::PgDumpError => e
        Failure(message: e.to_s)
      end
    end
  end
end
