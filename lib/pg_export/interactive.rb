require 'pg_export/interactive/refinements/colourable_string'

class PgExport
  module Interactive
    include CliSpinnable
    using ColourableString

    def self.extended(_)
      puts 'Interactive mode, for restoring dump into database.'.green
    end

    def call
      initialize_dump_storage
      print_all_dumps
      selected_dump = select_dump
      download_dump(selected_dump)
      [].tap do |arr|
        arr << Thread.new { restore_downloaded_dump }
        arr << Thread.new { close_connection }
      end.each(&:join)

      puts 'Success'.green
      self
    end

    private

    def initialize_dump_storage
      with_spinner do |cli|
        cli.print 'Connecting to FTP'
        super
        cli.tick
      end
    end

    def print_all_dumps
      dumps.each.with_index(1) do |name, i|
        print "(#{i}) "
        puts name.to_s.gray
      end
      self
    end

    def select_dump
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
      with_spinner do |cli|
        cli.print "Downloading dump #{name}"
        encrypted_dump = dump_storage.download(name)
        cli.print " (#{encrypted_dump.size_human})"
        cli.tick
        cli.print "Decrypting dump #{name}"
        self.dump = utils.decrypt(encrypted_dump)
        cli.print " (#{dump.size_human})"
        cli.tick
      end
      self
    rescue OpenSSL::Cipher::CipherError => e
      puts "Problem decrypting dump file: #{e}. Try again.".red
      retry
    end

    def restore_downloaded_dump
      puts 'To which database you would like to restore the downloaded dump?'
      if config.database == 'undefined'
        print 'Enter a local database name: '
      else
        print "Enter a local database name (#{config.database}): "
      end
      database = gets.chomp
      database = database.empty? ? config.database : database
      with_spinner do |cli|
        cli.print "Restoring dump to #{database} database"
        utils.restore_dump(dump, database)
        cli.tick
      end
      self
    rescue PgRestoreError => e
      puts e.to_s.red
      retry
    end

    def close_connection
      dump_storage.close_connection
    end

    def dumps
      @dumps ||= dump_storage.all
    end
  end
end
