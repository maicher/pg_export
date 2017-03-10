class PgExport
  class DumpStorage
    include Logging

    TIMESTAMP = '_%Y%m%d_%H%M%S'.freeze
    TIMESTAMP_REGEX = '[0-9]{8}_[0-9]{6}'.freeze

    def initialize(ftp_service, name, keep)
      @ftp_service, @name, @keep = ftp_service, name, keep
    end

    def upload(dump)
      dump_name = timestamped_name(dump)
      ftp_service.upload_file(dump.path, dump_name)
      logger.info "Upload #{dump} #{dump_name} to #{ftp_service}"
    end

    def download(name)
      dump = EncryptedDump.new
      ftp_service.download_file(dump.path, name)
      logger.info "Download #{dump} #{name} from #{ftp_service}"
      dump
    end

    def remove_old
      find_by_name(name).drop(keep.to_i).each do |filename|
        ftp_service.delete(filename)
        logger.info "Remove #{filename} from #{ftp_service}"
      end
    end

    def find_by_name(s)
      ftp_service.list(s + '_*')
    end

    def all
      ftp_service.list('*')
    end

    private

    attr_reader :ftp_service, :name, :keep

    def timestamped_name(dump)
      name + Time.now.strftime(TIMESTAMP) + dump.ext
    end
  end
end
