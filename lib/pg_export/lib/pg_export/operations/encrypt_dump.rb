# frozen_string_literal: true

require 'pg_export/import'

class PgExport
  module Operations
    class EncryptDump
      include Import['factories.cipher_factory', 'logger']

      def call(source_dump)
        target_dump = source_dump.copy(name: 'Encrypted Dump', cipher: cipher_factory.encryptor)
        logger.info "Create #{target_dump}"
        target_dump
      end
    end
  end
end
