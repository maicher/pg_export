class PgExport
  module Aes
    class Decryptor < Base
      def target_dump_name
        'Dump'.freeze
      end

      def cipher_type
        :decrypt
      end
    end
  end
end
