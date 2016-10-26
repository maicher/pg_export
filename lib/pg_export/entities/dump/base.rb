class PgExport
  module Dump
    class Base
      extend Forwardable
      include SizeHuman

      CHUNK_SIZE = (2**16).freeze

      def_delegators :file, :path, :read, :write, :<<, :rewind, :close, :size, :eof?

      def initialize
        @file = Tempfile.new('dump')
      end

      def ext
        ''
      end

      def open(operation_type, &block)
        case operation_type.to_sym
          when :read then File.open(path, 'r', &block)
          when :write then File.open(path, 'w', &block)
          else raise ArgumentError, 'Operation type can be only :read or :write'
        end
      end

      def to_s
        "#{name || self.class} #{file.class} (#{size_human})"
      end

      private

      attr_reader :file
    end
  end
end
