class PgExport
  class Aes
    ALG = 'AES-128-CBC'.freeze

    class << self
      def encryptor(key)
        initialize_aes(:encrypt, key)
      end

      def decryptor(key)
        initialize_aes(:decrypt, key)
      end

      private

      def initialize_aes(mode, key)
        raise ArgumentError, 'Only :encrypt or :decrypt are allowed' unless %i(encrypt decrypt).include?(mode)
        aes = OpenSSL::Cipher.new(ALG)
        aes.public_send(mode.to_sym)
        aes.key = key
        aes
      end
    end
  end
end
