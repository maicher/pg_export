class PgExport
  class FtpService
    class Connection
      include Logging

      attr_reader :ftp

      def initialize(host:, user:, password:)
        @host, @user, @password = host, user, password
        open
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

      attr_reader :host, :user, :password
    end
  end
end
