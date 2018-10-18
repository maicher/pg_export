# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class EncryptDump
      include Dry::Transaction::Operation
      include Import['factories.cipher_factory']

      def call(dump:)
        dump.encrypt(cipher_factory: cipher_factory)
        Success(dump: dump)
      end
    end
  end
end
