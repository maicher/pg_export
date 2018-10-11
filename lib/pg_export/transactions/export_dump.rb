# frozen_string_literal: true

require 'pg_export/version'
require 'pg_export/boot_container'
require 'dry/transaction'

class PgExport
  module Transactions
    class ExportDump
      include Dry::Transaction

      attr_accessor :container

      step :prepare_params
      step :build_dump
      step :export

      private

      def prepare_params(database_name:, keep_dumps:)
        database_name = database_name.to_s

        return Failure(message: 'Invalid database name') unless database_name.length > 0

        begin
          keep_dumps = Integer(keep_dumps)
        rescue TypeError, ArgumentError
          return Failure(message: 'Invalid keep_dumps')
        end

        Success(database_name: database_name, keep_dumps: keep_dumps)
      end

      def build_dump(database_name:, keep_dumps:)
        dump = bash_factory.build_dump(database_name)

        Success(dump: dump, database_name: database_name, keep_dumps: keep_dumps)
      rescue Bash::Adapter::PgDumpError => e
        return Failure(message: e.to_s)
      end

      def export(database_name:, keep_dumps:, dump:)
        encrypted_dump = encryptor.call(dump)
        ftp_repository.persist(encrypted_dump)
        ftp_repository.remove_old(database_name, keep_dumps)
        Success({})
      end

      def bash_factory
        container[:bash_factory]
      end

      def encryptor
        container[:encryptor]
      end

      def ftp_repository
        container[:ftp_repository]
      end
    end
  end
end
