# frozen_string_literal: true

class PgExport
  module Ftp
    class Adapter
      CHUNK_SIZE = (2**16).freeze

      def initialize(ftp_connection:)
        @ftp_connection = ftp_connection
        @host = ftp_connection.host
        ObjectSpace.define_finalizer(self, proc { ftp_connection.close })
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
        ftp_connection.ftp
      end

      def to_s
        host
      end

      private

      attr_reader :ftp_connection, :host
    end
  end
end
