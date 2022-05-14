# frozen_string_literal: true

require 'openssl'

class PgExport
  module Factories
    class CipherFactory
      def initialize(config:)
        @config = config
      end

      def encryptor
        build_cipher(:encrypt)
      end

      def decryptor
        build_cipher(:decrypt)
      end

      private

      attr_reader :config

      def build_cipher(type)
        cipher = OpenSSL::Cipher.new(config.encryption_algorithm)
        cipher.public_send(type)
        cipher.key = config.encryption_key
        cipher
      end
    end
  end
end
