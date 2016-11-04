require 'pg_export/interactive/refinements/colourable_string'

class PgExport
  module Interactive
    using ColourableString

    def self.extended(_)
      puts 'Starting interactive mode, for restoring dumps into databases'.green
    end

    def call
      initialize_dump_storage
      print_all_dumps
      download_selected_dump
      restore_downloaded_dump
      self
    end

    private

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
      print 'Downloading dump..'
      encrypted_dump = dump_storage.download(name)
      puts 'done'.green + " #{encrypted_dump.size_human}"
      print 'Decrypting dump..'
      self.dump = utils.decrypt(encrypted_dump)
      puts 'done'.green + " #{dump.size_human}"
      self
    rescue OpenSSL::Cipher::CipherError => e
      puts "Problem decrypting dump file: #{e}".red
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
      print 'Restoring..'
      utils.restore_dump(dump, database.empty? ? config.database : database)
      puts 'done'.green
      puts 'Success'.green
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
