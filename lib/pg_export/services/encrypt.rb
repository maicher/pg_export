class PgExport
  class Encrypt
    include Logging

    def initialize(encryptor)
      @encryptor = encryptor
    end

    def call(dump)
      enc_dump = EncryptedDump.new
      copy_using(encryptor, from: dump, to: enc_dump)
      logger.info "Create #{enc_dump}"
      enc_dump
    end

    private

    attr_reader :encryptor

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
