require 'openssl'

class PgExport
  module Aes
    class Base
      ALGORITHM = 'AES-128-CBC'.freeze

      include Logging

      def initialize(key:)
        @key = key
      end

      def call(source_dump)
        target_dump = Dump.new(target_dump_name)
        copy(from: source_dump, to: target_dump)
        logger.info "Create #{target_dump}"
        target_dump
      end

      private

      attr_reader :key

      def copy(from:, to:)
        cipher.reset
        to.open(:write) do |f|
          from.each_chunk do |chunk|
            f << cipher.update(chunk)
          end
          f << cipher.final
        end
        self
      end

      def cipher
        @cipher ||= build_cipher
      end

      def build_cipher
        OpenSSL::Cipher.new(ALGORITHM).tap do |cipher|
          cipher.public_send(cipher_type)
          cipher.key = key
        end
      end
    end
  end
end
