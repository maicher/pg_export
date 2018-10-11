# frozen_string_literal: true

class PgExport
  module Aes
    class Encryptor < Base
      def target_dump_name
        'Encrypted Dump'
      end

      def cipher_type
        :encrypt
      end
    end
  end
end
