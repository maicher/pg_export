class PgExport
  class DumpStorage
    include Logging

    TIMESTAMP = '_%Y%m%d_%H%M%S'.freeze
    TIMESTAMP_REGEX = '[0-9]{8}_[0-9]{6}'.freeze

    def initialize(ftp_service, name)
      @ftp_service, @name = ftp_service, name
    end

    def upload(dump)
      dump_name = timestamped_name(dump)
      ftp_service.upload_file(dump.path, dump_name)
      logger.info "Export #{dump} #{dump_name} to #{ftp_service}"
    end

    def remove_old(keep:)
      ftp_service.list(ftp_regex).drop(keep.to_i).each do |filename|
        ftp_service.delete(filename)
        logger.info "Remove #{filename} from FTP"
      end
    end

    private

    attr_reader :ftp_service, :name

    def timestamped_name(dump)
      name + Time.now.strftime(TIMESTAMP) + dump.ext
    end

    def ftp_regex
      name + '_*'
    end
  end
end
