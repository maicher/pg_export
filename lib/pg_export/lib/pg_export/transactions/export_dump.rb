# frozen_string_literal: true

require 'pg_export/version'
require 'dry/transaction'
require 'pg_export/import'

class PgExport
  module Transactions
    class ExportDump
      include Dry::Transaction
      include Import[
        'factories.dump_factory',
        'operations.encrypt_dump',
        'repositories.ftp_dump_repository',
        'logger'
      ]

      step :prepare_params
      step :build_dump
      step :export
      step :remove_old

      private

      def prepare_params(database_name:, keep_dumps:)
        database_name = database_name.to_s

        return Failure(message: 'Invalid database name') if database_name.empty?

        begin
          keep_dumps = Integer(keep_dumps)
        rescue TypeError, ArgumentError
          return Failure(message: 'Invalid keep_dumps')
        end

        Success(database_name: database_name, keep_dumps: keep_dumps)
      end

      def build_dump(database_name:, keep_dumps:)
        dump = dump_factory.from_database(database_name)

        Success(dump: dump, database_name: database_name, keep_dumps: keep_dumps)
      rescue Services::Bash::PgDumpError => e
        Failure(message: e.to_s)
      end

      def export(database_name:, keep_dumps:, dump:)
        encrypted_dump = encrypt_dump.call(dump)
        ftp_dump_repository.persist(encrypted_dump)
        logger.info "Persist #{encrypted_dump} #{encrypted_dump.timestamped_name} to #{ftp_dump_repository.ftp_adapter}"
        Success(database_name: database_name, keep_dumps: keep_dumps)
      end

      def remove_old(database_name:, keep_dumps:)
        ftp_dump_repository.by_name(database_name).drop(keep_dumps).each do |filename|
          ftp_dump_repository.delete(filename)
          logger.info "Remove #{filename} from #{ftp_dump_repository.ftp_adapter}"
        end
        Success({})
      end
    end
  end
end
