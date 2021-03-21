# frozen_string_literal: true

require 'openssl'
require 'pg_export/import'

class PgExport
  module Factories
    class CipherFactory
      include Import['config']

      def encryptor
        build_cipher(:encrypt)
      end

      def decryptor
        build_cipher(:decrypt)
      end

      private

      def build_cipher(type)
        cipher = OpenSSL::Cipher.new(config.encryption_algorithm)
        cipher.public_send(type)
        cipher.key = config.encryption_key
        cipher
      end
    end
  end
end
