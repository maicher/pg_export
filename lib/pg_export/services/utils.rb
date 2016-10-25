class PgExport
  class Utils
    extend Logging

    def self.create_dump(database_name)
      dump = SqlDump.new
      out = `pg_dump -Fc --file #{dump.path} #{database_name} 2>&1`
      raise PgDumpError, out if /FATAL/ =~ out
      logger.info "Create #{dump}"
      dump
    end

    def self.compress(dump)
      dump_gz = CompressedDump.new
      dump_gz.open(:write) do |gz|
        gz.write(dump.read_chunk) until dump.eof?
      end

      logger.info "Create #{dump_gz}"
      dump_gz
    end

    def self.decompress(dump_gz)
      dump = SqlDump.new
      dump_gz.open(:read) do |gz|
        dump.write(gz.readpartial(Dump::Base::CHUNK_SIZE)) until gz.eof?
      end
      dump.rewind

      logger.info "Create #{dump}"
      dump
    end
  end
end