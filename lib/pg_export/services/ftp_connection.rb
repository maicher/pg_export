class PgExport
  class FtpConnection
    include Logging

    attr_reader :ftp, :host

    def initialize(host:, user:, password:)
      @host, @user, @password = host, user, password
    end

    def open
      @ftp = Net::FTP.new(host, user, password)
      @ftp.passive = true
      logger.info "Connect to #{host}"
      self
    end

    def close
      @ftp.close
      logger.info 'Close FTP'
      self
    end

    private

    attr_reader :user, :password
  end
end
