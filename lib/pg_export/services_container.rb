class PgExport
  class ServicesContainer
    class << self
      def config
        @config ||= Configuration.new
      end

      def utils
        @utils ||= Utils.new(
          Aes.encryptor(config.dump_encryption_key),
          Aes.decryptor(config.dump_encryption_key)
        )
      end

      def connection_initializer
        proc { connection }
      end

      def connection_closer
        proc { connection.close }
      end

      def connection
        @connection ||= FtpService::Connection.new(config.ftp_params)
      end

      def ftp_service
        @ftp_service ||= FtpService.new(connection)
      end

      def dump_storage
        @dump_storage ||= DumpStorage.new(ftp_service, config.database)
      end
    end
  end
end
