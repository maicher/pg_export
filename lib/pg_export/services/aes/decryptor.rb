class PgExport
  class Aes
    class Decryptor < Base
      def call(enc_dump)
        dump = PlainDump.new
        copy_using(cipher, from: enc_dump, to: dump)
        logger.info "Create #{dump}"
        dump
      end
    end
  end
end
