# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class EncryptDump
      include Dry::Transaction::Operation
      include Import['factories.cipher_factory', 'logger']

      def call(database_name:, dump:)
        target_dump = dump.copy(name: 'Encrypted Dump', cipher: cipher_factory.encryptor)
        logger.info "Create #{target_dump}"
        Success(database_name: database_name, dump: target_dump)
      end
    end
  end
end
