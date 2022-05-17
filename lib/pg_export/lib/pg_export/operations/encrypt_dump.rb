# frozen_string_literal: true

require 'pg_export/lib/pg_export/value_objects/result'

class PgExport
  module Operations
    class EncryptDump
      def initialize(cipher_factory:)
        @cipher_factory = cipher_factory
      end

      def name
        :encrypt_dump
      end

      def call(dump:)
        dump.encrypt(cipher_factory: cipher_factory)

        ValueObjects::Success.new(dump: dump)
      end

      private

      attr_reader :cipher_factory
    end
  end
end
