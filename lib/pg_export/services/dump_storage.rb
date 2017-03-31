class PgExport
  class DumpStorage
    include Logging

    TIMESTAMP = '_%Y%m%d_%H%M%S'.freeze
    TIMESTAMP_REGEX = '[0-9]{8}_[0-9]{6}'.freeze

    def initialize(ftp_adapter, name, keep)
      @ftp_adapter, @name, @keep = ftp_adapter, name, keep
    end

    def upload(dump)
      dump_name = timestamped_name(dump)
      ftp_adapter.upload_file(dump.path, dump_name)
      logger.info "Upload #{dump} #{dump_name} to #{ftp_adapter}"
    end

    def download(name)
      dump = Dump.new('Encrypted Dump')
      ftp_adapter.download_file(dump.path, name)
      logger.info "Download #{dump} #{name} from #{ftp_adapter}"
      dump
    end

    def remove_old
      find_by_name(name).drop(keep.to_i).each do |filename|
        ftp_adapter.delete(filename)
        logger.info "Remove #{filename} from #{ftp_adapter}"
      end
    end

    def find_by_name(s)
      ftp_adapter.list(s + '_*')
    end

    def all
      ftp_adapter.list('*')
    end

    private

    attr_reader :ftp_adapter, :name, :keep

    def timestamped_name(dump)
      name + Time.now.strftime(TIMESTAMP) + dump.ext
    end
  end
end
