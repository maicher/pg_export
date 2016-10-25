class PgExport
  module Dump
    class Base
      extend Forwardable
      include SizeHuman

      CHUNK_SIZE = (2**16).freeze

      def_delegators :file, :path, :read, :write, :rewind, :size, :eof?

      def initialize
        @file = Tempfile.new('dump')
      end

      def ext
        raise 'Overwrite it'
      end

      def read_chunk
        raise 'Overwrite it'
      end

      def to_s
        "#{name || self.class} #{file.class} (#{size_human})"
      end

      private

      attr_reader :file
    end
  end
end
