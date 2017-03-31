class PgExport
  class Aes
    class Encryptor < Base
      def call(dump)
        enc_dump = Dump.new('Encrypted Dump')
        copy_using(cipher, from: dump, to: enc_dump)
        logger.info "Create #{enc_dump}"
        enc_dump
      end
    end
  end
end
