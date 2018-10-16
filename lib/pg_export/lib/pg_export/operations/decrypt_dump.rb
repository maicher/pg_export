# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class DecryptDump
      include Import['factories.cipher_factory']

      def call(source_dump)
        source_dump.decrypt(cipher_factory: cipher_factory)
        source_dump
      end
    end
  end
end
