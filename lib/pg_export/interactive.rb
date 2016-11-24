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
      download_selected_dump
      restore_downloaded_dump
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
      dumps.each.with_index(0) do |name, i|
        print "(#{i}) "
        puts name.to_s.gray
      end
      self
    end

    def download_selected_dump
      puts 'Which dump would you like to import?'
      print "Type from 1 to #{dumps.count - 1} (0): "
      name = dumps.fetch(gets.chomp.to_i)
      with_spinner do |cli|
        cli.print 'Downloading dump'
        encrypted_dump = dump_storage.download(name)
        cli.print " (#{encrypted_dump.size_human})"
        cli.tick
        cli.print 'Decrypting dump'
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

    def dumps
      @dumps ||= dump_storage.all
    end
  end
end
