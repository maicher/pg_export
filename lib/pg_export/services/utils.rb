class PgExport
  class Utils
    include Logging

    def initialize(encryptor, decryptor)
      @encryptor, @decryptor = encryptor, decryptor
    end

    def create_dump(database_name)
      dump = PlainDump.new
      Open3.popen3("pg_dump -Fc --file #{dump.path} #{database_name}") do |_, _, err|
        error = err.read
        raise PgDumpError, error unless error.empty?
      end
      logger.info "Create #{dump}"
      dump
    end

    def restore_dump(dump, database_name)
      Open3.popen3("pg_restore -c -d #{database_name} #{dump.path}") do |_, _, err|
        error = err.read
        raise PgRestoreError, error if /FATAL/ =~ error
      end
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
      aes.reset
      to.open(:write) do |f|
        from.each_chunk do |chunk|
          f << aes.update(chunk)
        end
        f << aes.final
      end
      self
    end
  end
end
