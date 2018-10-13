# frozen_string_literal: true

require 'pg_export/import'

class PgExport
  module Operations
    class EncryptDump
      include Import['cipher_factory', 'operations.copy_dump']

      def call(source_dump)
        target_dump = ValueObjects::Dump.new(name: 'Encrypted Dump', db_name: source_dump.db_name)
        copy_dump.call(from: source_dump, to: target_dump, cipher: cipher_factory.encryptor)
        target_dump
      end
    end
  end
end
