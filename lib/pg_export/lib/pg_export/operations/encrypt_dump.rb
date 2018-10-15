# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class EncryptDump
      include Dry::Transaction::Operation
      include Import['factories.cipher_factory', 'factories.dump_factory', 'logger']

      def call(database_name:, dump:)
        dump.encrypt(cipher_factory: cipher_factory)
        logger.info "Create #{dump}"
        Success(database_name: database_name, dump: dump)
      end
    end
  end
end
