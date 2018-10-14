# frozen_string_literal: true

require 'net/ftp'

class PgExport
  module Adapters
    class FtpAdapter
      CHUNK_SIZE = (2**16).freeze

      def initialize(host:, user:, password:, logger:)
        @host, @user, @password, @logger = host, user, password, logger
        open_ftp_thread
        ObjectSpace.define_finalizer(self, proc { ftp.close; logger.info 'Close FTP' })
      end

      def open_ftp_thread
        @open_ftp_thread ||= Thread.new { open_ftp }
      end

      def open_ftp
        @ftp = Net::FTP.new(host, user, password)
        @ftp.passive = true
        logger.info "Connect to #{host}"
        self
      end

      def list(regex_string)
        ftp.list(regex_string).map { |item| item.split(' ').last }.sort.reverse
      end

      def delete(filename)
        ftp.delete(filename)
      end

      def persist(path, timestamped_name)
        ftp.putbinaryfile(path, timestamped_name, CHUNK_SIZE)
      end

      def get(path, timestamped_name)
        ftp.getbinaryfile(timestamped_name, path, CHUNK_SIZE)
      end

      def ftp
        open_ftp_thread.join
        @ftp
      end

      def to_s
        host
      end

      private

      attr_reader :host, :user, :password, :logger
    end
  end
end
