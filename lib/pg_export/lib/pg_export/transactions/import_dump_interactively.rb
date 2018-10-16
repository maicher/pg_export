# frozen_string_literal: true

# auto_register: false

require 'dry/transaction'

require 'pg_export/roles/colourable_string'
require 'pg_export/import'
require 'pg_export/container'
require 'tty-prompt'
require 'tty-spinner'

class PgExport
  module Transactions
    class ImportDumpInteractively
      include Dry::Transaction(container: PgExport::Container)
      using Roles::ColourableString
      include Import[
        'operations.decrypt_dump',
        'adapters.bash_adapter',
        'repositories.ftp_dump_repository',
        'repositories.ftp_dump_file_repository',
        'factories.ftp_adapter_factory'
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
        spinner = TTY::Spinner.new('[:spinner] Opening ftp connection...')
        spinner.auto_spin
        ftp_adapter = ftp_adapter_factory.ftp_adapter
        ftp_adapter.open_ftp
        spinner.success('done'.green)
        Success(database_name: database_name, ftp_adapter: ftp_adapter)
      end

      def fetch_dumps_from_ftp(database_name:, ftp_adapter:)
        spinner = TTY::Spinner.new('[:spinner] Fetching dumps...')
        spinner.auto_spin
        dumps = ftp_dump_repository.all(database_name: database_name, ftp_adapter: ftp_adapter)
        spinner.success('done'.green)
        Success(ftp_adapter: ftp_adapter, dumps: dumps)
      end

      def select_dump(dumps:, ftp_adapter:)
        prompt = TTY::Prompt.new
        idx = prompt.select('Select dump to import:') do |menu|
          menu.enum '.'
          dumps.each_with_index do |d, i|
            menu.choice(d.name, i)
          end
        end

        Success(dump: dumps[idx], ftp_adapter: ftp_adapter)
      end

      def download_dump_from_ftp(dump:, ftp_adapter:)
        spinner = TTY::Spinner.new('[:spinner] Downloading...')
        spinner.auto_spin
        dump.file = ftp_dump_file_repository.by_name(name: dump.name, ftp_adapter: ftp_adapter)
        spinner.success('done'.green + " #{dump}")

        Success(dump: dump, ftp_adapter: ftp_adapter)
      end

      def close_ftp_connection(dump:, ftp_adapter:)
        Thread.new { ftp_adapter.close_ftp }
        Success(dump: dump)
      end

      def decrypt_dump_step(dump:)
        spinner = TTY::Spinner.new('[:spinner] Decrypting...')
        spinner.auto_spin
        dump = decrypt_dump.call(dump)
        spinner.success('done'.green + " #{dump}")

        Success(dump: dump)
      rescue OpenSSL::Cipher::CipherError => e
        spinner.error
        Failure(message: "Problem decrypting dump file: #{e}. Try again.".red)
      end

      def restore(dump:)
        prompt = TTY::Prompt.new
        puts 'To which database would you like to restore the downloaded dump?'
        name = prompt.ask('Enter a local database name:') do |q|
          q.required(true)
          q.default(dump.database) if dump.database
        end

        spinner = TTY::Spinner.new('[:spinner] Restoring...')
        spinner.auto_spin
        bash_adapter.pg_restore(dump.file, name)
        spinner.success('done'.green)

        Success({})
      rescue bash_adapter.class::PgRestoreError => e
        spinner.error
        Failure(message: e.to_s)
      end
    end
  end
end
