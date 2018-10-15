# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class DecryptDump
      include Import['factories.cipher_factory', 'factories.dump_factory', 'logger']

      def call(source_dump)
        source_dump.decrypt(cipher_factory: cipher_factory)
        logger.info "Create #{source_dump}"
        source_dump
      end
    end
  end
end
