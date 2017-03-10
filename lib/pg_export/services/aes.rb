class PgExport
  class Aes
    ALGORITHM = 'AES-128-CBC'.freeze

    def initialize(key)
      @key = key
    end

    def build_encryptor
      Aes::Encryptor.new(cipher(:encrypt))
    end

    def build_decryptor
      Aes::Decryptor.new(cipher(:decrypt))
    end

    private

    attr_reader :key

    def cipher(mode)
      OpenSSL::Cipher.new(ALGORITHM).tap do |cipher|
        cipher.public_send(mode.to_sym)
        cipher.key = key
      end
    end
  end
end
