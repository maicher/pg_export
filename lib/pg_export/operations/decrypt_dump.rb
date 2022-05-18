# frozen_string_literal: true

require 'pg_export'
require 'pg_export/value_objects/result'

class PgExport
  module Operations
    class DecryptDump
      def initialize(cipher_factory:)
        @cipher_factory = cipher_factory
      end

      def name
        :decrypt_dump
      end

      def call(dump:)
        dump.decrypt(cipher_factory: cipher_factory)

        ValueObjects::Success.new(dump: dump)
      rescue OpenSSL::Cipher::CipherError => e
        ValueObjects::Failure.new(message: "Problem decrypting dump file: #{e}. Try again.")
      end

      private

      attr_reader :cipher_factory
    end
  end
end
