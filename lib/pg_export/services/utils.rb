class PgExport
  class Utils
    include Logging

    def initialize(encryptor, decryptor)
      @encryptor, @decryptor = encryptor, decryptor
    end

    def create_dump(database_name)
      dump = SqlDump.new
      out = `pg_dump -Fc --file #{dump.path} #{database_name} 2>&1`
      raise PgDumpError, out if /FATAL/ =~ out
      logger.info "Create #{dump}"
      dump
    end

    def encrypt(dump)
      enc_dump = EncryptedDump.new
      dump.open(:read) do |f|
        enc_dump.open(:write) do |enc|
          enc << encryptor.update(f.read(Dump::Base::CHUNK_SIZE)) until f.eof?
          enc << encryptor.final
        end
      end

      logger.info "Create #{enc_dump}"
      enc_dump
    end

    def decrypt(enc_dump)
      dump = SqlDump.new
      enc_dump.open(:read) do |enc|
        dump.open(:write) do |f|
          f << decryptor.update(enc.read(Dump::Base::CHUNK_SIZE)) until enc.eof?
          f << decryptor.final
        end
      end

      logger.info "Create #{dump}"
      dump
    end

    private

    attr_reader :encryptor, :decryptor
  end
end
