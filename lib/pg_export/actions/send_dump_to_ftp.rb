class PgExport
  class SendDumpToFtp
    include Logging

    def initialize(dump, ftp_service)
      @dump = dump
      @ftp_service = ftp_service
    end

    def call
      ftp_service.upload_file(dump.pathname_gz)
      logger.info "Export #{dump.basename_gz} to FTP"
    end

    private

    attr_reader :dump, :ftp_service
  end
end
