require 'net/ftp'

class PgExport
  module Ftp
    class Connection
      attr_reader :ftp, :host

      def initialize(host:, user:, password:, logger:)
        @host, @user, @password, @logger = host, user, password, logger
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

      attr_reader :user, :password, :logger
    end
  end
end
