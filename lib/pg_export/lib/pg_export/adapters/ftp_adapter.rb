# frozen_string_literal: true

require 'net/ftp'

class PgExport
  module Adapters
    class FtpAdapter
      CHUNK_SIZE = (2**16).freeze

      def initialize(host:, user:, password:, logger:)
        @host, @user, @password, @logger = host, user, password, logger
        ObjectSpace.define_finalizer(self, proc do
                                             return unless @ftp

                                             ftp.close
                                             logger.info 'Close FTP'
                                           end)
      end

      def open_ftp
        @ftp = Net::FTP.new(host, user, password)
        @ftp.passive = true
        logger.info "Connect to #{host}"
        @ftp
      end

      def list(regex_string)
        ftp.list(regex_string).map { |item| item.split(' ').last }.sort.reverse
      end

      def delete(filename)
        ftp.delete(filename)
      end

      def persist(file, name)
        ftp.putbinaryfile(file.path, name, CHUNK_SIZE)
      end

      def get(file, name)
        ftp.getbinaryfile(name, file.path, CHUNK_SIZE)
      end

      def to_s
        host
      end

      def ftp
        @ftp ||= open_ftp
      end

      private

      attr_reader :host, :user, :password, :logger
    end
  end
end
