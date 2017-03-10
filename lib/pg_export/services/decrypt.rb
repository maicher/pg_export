class PgExport
  class Decrypt
    include Logging

    def initialize(decryptor)
      @decryptor = decryptor
    end

    def call(enc_dump)
      dump = PlainDump.new
      copy_using(decryptor, from: enc_dump, to: dump)
      logger.info "Create #{dump}"
      dump
    end

    private

    attr_reader :decryptor

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