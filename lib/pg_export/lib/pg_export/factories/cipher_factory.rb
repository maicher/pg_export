# frozen_string_literal: true

require 'openssl'

class PgExport
  module Factories
    class CipherFactory
      def initialize(encryption_algorithm:, encryption_key:)
        @encryption_algorithm = encryption_algorithm
        @encryption_key = encryption_key
      end

      def encryptor
        build_cipher(:encrypt)
      end

      def decryptor
        build_cipher(:decrypt)
      end

      private

      attr_reader :encryption_algorithm, :encryption_key

      def build_cipher(type)
        cipher = OpenSSL::Cipher.new(encryption_algorithm)
        cipher.public_send(type)
        cipher.key = encryption_key
        cipher
      end
    end
  end
end
