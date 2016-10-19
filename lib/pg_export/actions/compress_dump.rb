class PgExport
  class CompressDump
    include Logging

    def initialize(dump)
      @dump = dump
    end

    def call
      validate_dumpfile_exists
      compress_dumpfile
      remove_dumpfile
      self
    end

    private

    attr_reader :dump

    def validate_dumpfile_exists
      File.exist?(dump.pathname) or raise DumpFileDoesNotExistError, "#{dump.pathname} does not exist"
    end

    def compress_dumpfile
      Zlib::GzipWriter.open(dump.pathname_gz) do |gz|
        File.open(dump.pathname) do |fp|
          while chunk = fp.read(16 * 1024)
            gz.write chunk
          end
        end
      end
      logger.info "Zip dump #{dump.basename_gz} (#{dump.size_gz})"
    end

    def remove_dumpfile
      File.delete(dump.pathname)
    end
  end
end
