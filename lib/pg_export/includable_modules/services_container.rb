class PgExport
  module ServicesContainer
    class << self
      def config
        @config ||= Configuration.new
      end

      def aes
        @aes ||= Aes.new(config.dump_encryption_key)
      end

      def encryptor
        @encryptor ||= aes.build_encryptor
      end

      def decryptor
        @decryptor ||= aes.build_decryptor
      end

      def bash_utils
        @bash_utils ||= BashUtils.new(config.database)
      end

      def ftp_connection
        @ftp_connection ||= FtpConnection.new(config.ftp_params)
      end

      def ftp_adapter
        @ftp_adapter ||= FtpAdapter.new(ftp_connection)
      end

      def dump_storage
        @dump_storage ||= DumpStorage.new(ftp_adapter, config.database, config.keep_dumps)
      end
    end

    def services_container
      @services_container ||= ServicesContainer
    end
  end
end
