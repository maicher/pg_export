# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class DecryptDump
      include Dry::Transaction::Operation
      include Import['factories.cipher_factory']

      def call(dump:)
        dump.decrypt(cipher_factory: cipher_factory)
        Success(dump: dump)
      rescue OpenSSL::Cipher::CipherError => e
        Failure(message: "Problem decrypting dump file: #{e}. Try again.".red)
      end
    end
  end
end
