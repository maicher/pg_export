class PgExport
  class ServicesContainer
    class << self
      def config
        @config ||= Configuration.new
      end

      def encryptor
        Aes.encryptor(config.dump_encryption_key)
      end

      def decryptor
        Aes.decryptor(config.dump_encryption_key)
      end

      def encrypt
        @encrypt ||= Encrypt.new(encryptor)
      end

      def decrypt
        @decrypt ||= Decrypt.new(decryptor)
      end

      def utils
        @utils ||= Utils.new(config.database)
      end

      def connection_initializer
        proc { ftp_connection }
      end

      def connection_closer
        proc { ftp_connection.close }
      end

      def ftp_connection
        @connection ||= FtpConnection.new(config.ftp_params)
      end

      def ftp_adapter
        @ftp_adapter ||= FtpAdapter.new(ftp_connection)
      end

      def dump_storage
        @dump_storage ||= DumpStorage.new(ftp_adapter, config.database, config.keep_dumps)
      end
    end
  end
end
