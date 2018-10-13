# frozen_string_literal: true

require 'pg_export/import'

class PgExport
  module Operations
    class DecryptDump
      include Import['factories.cipher_factory', 'logger']

      def call(source_dump)
        target_dump = source_dump.copy(name: 'Dump', cipher: cipher_factory.decryptor)
        logger.info "Create #{target_dump}"
        target_dump
      end
    end
  end
end
