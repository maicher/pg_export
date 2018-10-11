require 'net/ftp'

class PgExport
  module Ftp
    class Connection
      attr_reader :host

      def initialize(host:, user:, password:, logger:)
        @host, @user, @password, @logger = host, user, password, logger
        open_ftp_thread
      end

      def ftp
        open_ftp_thread.join
        @ftp
      end

      def close
        ftp.close
        logger.info 'Close FTP'
        self
      end

      def open
        @ftp = Net::FTP.new(host, user, password)
        @ftp.passive = true
        logger.info "Connect to #{host}"
        self
      end

      private

      attr_reader :user, :password, :logger

      def open_ftp_thread
        @open_ftp_thread ||= Thread.new { open }
      end
    end
  end
end
