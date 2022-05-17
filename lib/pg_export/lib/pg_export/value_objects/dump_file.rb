# frozen_string_literal: true

require 'tempfile'

class PgExport
  module ValueObjects
    class DumpFile
      def initialize(file = Tempfile.new)
        @file = file
      end

      def path
        file.path
      end

      def size
        file.size
      end

      def rewind
        file.rewind
      end

      def read
        file.read
      end

      def copy(cipher:)
        cipher.reset
        new_self = self.class.new
        new_self.write do |f|
          each_chunk do |chunk|
            f << cipher.update(chunk)
          end
          f << cipher.final
        end

        new_self
      end

      def write(&block)
        File.open(path, 'w', &block)
      end

      def each_chunk
        File.open(path, 'r') do |file|
          yield file.read(CHUNK_SIZE) until file.eof?
        end
      end

      def size_human
        MAPPING.each_pair { |e, s| return "#{(size.to_f / (s / 1024)).round(2)}#{e}" if size < s }
      end

      private

      CHUNK_SIZE = (2**16)
      MAPPING = {
        'B' => 1024,
        'kB' => 1024 * 1024,
        'MB' => 1024 * 1024 * 1024,
        'GB' => 1024 * 1024 * 1024 * 1024,
        'TB' => 1024 * 1024 * 1024 * 1024 * 1024
      }.freeze
      private_constant :CHUNK_SIZE, :MAPPING

      attr_reader :file
    end
  end
end
