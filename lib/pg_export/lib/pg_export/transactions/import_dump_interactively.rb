# frozen_string_literal: true

require 'dry/transaction'

require 'pg_export/import'
require 'pg_export/container'

class PgExport
  module Transactions
    class ImportDumpInteractively
      include Dry::Transaction(container: PgExport::Container)
      include Import[
        'operations.decrypt_dump',
        'adapters.bash_adapter',
        'repositories.ftp_dump_repository',
        'repositories.ftp_dump_file_repository',
        'factories.ftp_adapter_factory',
        'ui.interactive.input',
        'ui.interactive.output'
      ]

      step :open_ftp_connection
      step :fetch_dumps_from_ftp
      step :select_dump
      step :download_dump_from_ftp
      step :close_ftp_connection
      step :decrypt_dump_step
      step :restore

      private

      def open_ftp_connection(database_name:)
        spinner = output.opening_ftp_connection
        ftp_adapter = ftp_adapter_factory.ftp_adapter
        ftp_adapter.open_ftp
        spinner.success(output.success)
        Success(database_name: database_name, ftp_adapter: ftp_adapter)
      end

      def fetch_dumps_from_ftp(database_name:, ftp_adapter:)
        spinner = output.fetching_dumps
        dumps = ftp_dump_repository.all(database_name: database_name, ftp_adapter: ftp_adapter)
        spinner.success(output.success)
        Success(ftp_adapter: ftp_adapter, dumps: dumps)
      end

      def select_dump(dumps:, ftp_adapter:)
        dump = input.select_dump(dumps)
        Success(dump: dump, ftp_adapter: ftp_adapter)
      end

      def download_dump_from_ftp(dump:, ftp_adapter:)
        spinner = output.downloading_dump_from_ftp
        dump.file = ftp_dump_file_repository.by_name(name: dump.name, ftp_adapter: ftp_adapter)
        spinner.success(output.success + " #{dump}")
        Success(dump: dump, ftp_adapter: ftp_adapter)
      end

      def close_ftp_connection(dump:, ftp_adapter:)
        Thread.new { ftp_adapter.close_ftp }
        Success(dump: dump)
      end

      def decrypt_dump_step(dump:)
        spinner = output.decrypting_dump
        dump = decrypt_dump.call(dump)
        spinner.success([output.success, dump].join(' '))

        Success(dump: dump)
      rescue OpenSSL::Cipher::CipherError => e
        spinner.error(output.error)
        Failure(message: "Problem decrypting dump file: #{e}. Try again.".red)
      end

      def restore(dump:)
        name = input.enter_database_name(dump.database)
        spinner = output.restoring
        bash_adapter.pg_restore(dump.file, name)
        spinner.success(output.success)

        Success({})
      rescue bash_adapter.class::PgRestoreError => e
        spinner.error(output.error)
        Failure(message: e.to_s)
      end
    end
  end
end
