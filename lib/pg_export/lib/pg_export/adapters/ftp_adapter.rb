# frozen_string_literal: true

require 'net/ftp'

class PgExport
  module Adapters
    class FtpAdapter
      CHUNK_SIZE = (2**16).freeze

      def initialize(host:, user:, password:)
        @host, @user, @password, @logger = host, user, password
        ObjectSpace.define_finalizer(self, proc { ftp.close if @ftp })
      end

      def open_ftp
        @ftp = Net::FTP.new(host, user, password)
        @ftp.passive = true
        @ftp
      end

      def close_ftp
        @ftp&.close
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

      attr_reader :host, :user, :password
    end
  end
end
