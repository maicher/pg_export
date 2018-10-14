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
        'logger',
        'config'
      ]

      step :prepare_params
      step :build_dump
      step :export
      step :remove_old

      private

      def prepare_params(database_name:)
        database_name = database_name.to_s

        return Failure(message: 'Invalid database name') if database_name.empty?

        Success(database_name: database_name)
      end

      def build_dump(database_name:)
        dump = dump_factory.from_database(database_name)

        Success(dump: dump, database_name: database_name)
      rescue Services::Bash::PgDumpError => e
        Failure(message: e.to_s)
      end

      def export(database_name:, dump:)
        encrypted_dump = encrypt_dump.call(dump)
        ftp_dump_repository.persist(encrypted_dump)
        logger.info "Persist #{encrypted_dump} #{encrypted_dump.timestamped_name} to #{ftp_dump_repository.ftp_adapter}"
        Success(database_name: database_name)
      end

      def remove_old(database_name:)
        ftp_dump_repository.by_name(database_name).drop(config.keep_dumps).each do |filename|
          ftp_dump_repository.delete(filename)
          logger.info "Remove #{filename} from #{ftp_dump_repository.ftp_adapter}"
        end
        Success({})
      end
    end
  end
end
