require_relative 'build_logger'

class PgExport
  module Services
    class BuildContainer
      class << self
        def call(config)
          container = {}
          container[:logger] = BuildLogger.call(stream: $stdout, format: config[:logger_format])
          container[:encryptor] = Aes::Encryptor.new(key: config[:dump_encryption_key], logger: container[:logger])
          container[:decryptor] = Aes::Decryptor.new(key: config[:dump_encryption_key], logger: container[:logger])
          container[:bash_utils] = BashUtils.new(database_name: config[:database], logger: container[:logger])
          container[:ftp_connection] = FtpConnection.new(
            host: config[:ftp_host],
            user: config[:ftp_user],
            password: config[:ftp_password],
            logger: container[:logger]
          )
          container[:ftp_adapter] = FtpAdapter.new(connection: container[:ftp_connection])
          container[:dump_storage] = DumpStorage.new(
            ftp_adapter: container[:ftp_adapter],
            name: config[:database],
            keep: config[:keep_dumps],
            logger: container[:logger]
          )
          container[:database] = config[:database]
          container
        end
      end
    end
  end
end
