class PgExport
  class Utils
    include Logging

    def initialize(encryptor, decryptor)
      @encryptor, @decryptor = encryptor, decryptor
    end

    def create_dump(database_name)
      dump = PlainDump.new
      out = `pg_dump -Fc --file #{dump.path} #{database_name} 2>&1`
      raise PgDumpError, out if /FATAL/ =~ out
      logger.info "Create #{dump}"
      dump
    end

    def restore_dump(dump, database_name)
      out = `pg_restore -c -d #{database_name} #{dump.path} 2>&1`
      raise PgRestoreError, out if /FATAL/ =~ out
      logger.info "Restore #{dump}"
      self
    end

    def encrypt(dump)
      enc_dump = EncryptedDump.new
      copy_using(encryptor, from: dump, to: enc_dump)
      logger.info "Create #{enc_dump}"
      enc_dump
    end

    def decrypt(enc_dump)
      dump = PlainDump.new
      copy_using(decryptor, from: enc_dump, to: dump)
      logger.info "Create #{dump}"
      dump
    end

    private

    attr_reader :encryptor, :decryptor

    def copy_using(aes, from:, to:)
      from.each_chunk do |chunk|
        to.open(:write) do |f|
          f << aes.update(chunk)
          f << aes.final
        end
      end
      self
    end
  end
end
