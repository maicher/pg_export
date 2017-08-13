require 'cli_spinnable'
require_relative 'colourable_string'

class PgExport
  module Roles
    module Interactive
      include CliSpinnable
      using ColourableString

      def self.extended(_)
        puts 'Interactive mode, for restoring dump into database.'.green
      end

      def call
        initialize_connection
        dumps = print_all_dumps
        dump = download_dump(select_dump(dumps))
        t = Thread.new { container[:ftp_connection].close }
        restore_downloaded_dump(dump)
        t.join
        puts 'Success'.green
        self
      end

      private

      def initialize_connection
        with_spinner do |cli|
          cli.print 'Connecting to FTP'
          container[:ftp_connection].ftp
          cli.tick
        end
      end

      def print_all_dumps
        dumps = container[:ftp_repository].all
        dumps.each.with_index(1) do |name, i|
          print "(#{i}) "
          puts name.to_s.gray
        end

        dumps
      end

      def select_dump(dumps)
        puts 'Which dump would you like to import?'
        number = loop do
          print "Type from 1 to #{dumps.count} (1): "
          number = gets.chomp.to_i
          break number if (1..dumps.count).cover?(number)
          puts 'Invalid number. Please try again.'.red
        end

        dumps.fetch(number - 1)
      end

      def download_dump(name)
        dump = nil

        with_spinner do |cli|
          cli.print "Downloading dump #{name}"
          encrypted_dump = container[:ftp_repository].get(name)
          cli.print " (#{encrypted_dump.size_human})"
          cli.tick
          cli.print "Decrypting dump #{name}"
          dump = container[:decryptor].call(encrypted_dump)
          cli.print " (#{dump.size_human})"
          cli.tick
        end

        dump
      rescue OpenSSL::Cipher::CipherError => e
        puts "Problem decrypting dump file: #{e}. Try again.".red
        retry
      end

      def restore_downloaded_dump(dump)
        puts 'To which database you would like to restore the downloaded dump?'
        if container[:database] == 'undefined'
          print 'Enter a local database name: '
        else
          print "Enter a local database name (#{config[:database]}): "
        end
        db_name = gets.chomp
        db_name = db_name.empty? ? config[:database] : db_name
        with_spinner do |cli|
          cli.print "Restoring dump to #{db_name} database"
          container[:bash_repository].persist(dump, db_name)
          cli.tick
        end
        self
      rescue PgRestoreError => e
        puts e.to_s.red
        retry
      end
    end
  end
end
