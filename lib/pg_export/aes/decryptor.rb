# frozen_string_literal: true

class PgExport
  module Aes
    class Decryptor < Base
      def target_dump_name
        'Dump'
      end

      def cipher_type
        :decrypt
      end
    end
  end
end
