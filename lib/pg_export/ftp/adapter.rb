class PgExport
  module Ftp
    class Adapter
      CHUNK_SIZE = (2**16).freeze

      def initialize(connection:)
        @connection = connection
        @host = connection.host
        ObjectSpace.define_finalizer(self, proc { connection.close })
      end

      def list(regex_string)
        ftp.list(regex_string).map { |item| item.split(' ').last }.sort.reverse
      end

      def delete(filename)
        ftp.delete(filename)
      end

      def upload_file(path, name)
        ftp.putbinaryfile(path.to_s, name, CHUNK_SIZE)
      end

      def download_file(path, name)
        ftp.getbinaryfile(name, path.to_s, CHUNK_SIZE)
      end

      def ftp
        connection.ftp
      end

      def to_s
        host
      end

      private

      attr_reader :connection, :host
    end
  end
end
