# frozen_string_literal: true

require 'openssl'
require 'pg_export/import'

class PgExport
  module Factories
    class CipherFactory
      include Import['config']

      def encryptor
        cipher(:encrypt)
      end

      def decryptor
        cipher(:decrypt)
      end

      private

      ALGORITHM = 'AES-128-CBC'
      private_constant :ALGORITHM

      def cipher(type)
        OpenSSL::Cipher.new(ALGORITHM).tap do |cipher|
          cipher.public_send(type)
          cipher.key = config.dump_encryption_key
        end
      end
    end
  end
end
