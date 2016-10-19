class PgExport
  class RemoveOldDumpsFromFtp
    include Logging

    def initialize(dump, ftp_service, keep_dumps)
      @dump = dump
      @ftp_service = ftp_service
      @keep_dumps = keep_dumps
    end

    def call
      ftp_service.list(dump.ftp_regexp).drop(keep_dumps).each do |filename|
        ftp_service.delete(filename)
        logger.info "Remove file #{filename} from FTP"
      end
    end

    private

    attr_accessor :dump, :ftp_service, :keep_dumps
  end
end
