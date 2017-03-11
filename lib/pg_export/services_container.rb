class PgExport
  class ServicesContainer
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

      def utils
        @utils ||= Utils.new(config.database)
      end

      def open_ftp_connection
        @open_ftp_connection ||= proc { ftp_connection.open }
      end

      def close_ftp_connection
        @close_ftp_connection ||= proc { ftp_connection.close }
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
