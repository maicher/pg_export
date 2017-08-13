require_relative 'services/build_logger'
require_relative 'ftp/adapter'
require_relative 'ftp/connection'
require_relative 'services/bash_utils'
require_relative 'repository'
require_relative 'factory'
require_relative 'aes'

class PgExport
  class BootContainer
    class << self
      def call(config)
        container = {}
        container[:logger] = Services::BuildLogger.call(stream: $stdout, format: config[:logger_format])
        container[:encryptor] = Aes::Encryptor.new(key: config[:dump_encryption_key], logger: container[:logger])
        container[:decryptor] = Aes::Decryptor.new(key: config[:dump_encryption_key], logger: container[:logger])
        container[:bash_utils] = BashUtils.new(database_name: config[:database], logger: container[:logger])
        container[:ftp_connection] = Ftp::Connection.new(
          host: config[:ftp_host],
          user: config[:ftp_user],
          password: config[:ftp_password],
          logger: container[:logger]
        )
        container[:ftp_adapter] = Ftp::Adapter.new(connection: container[:ftp_connection])
        container[:repository] = Repository.new(
          adapter: container[:ftp_adapter],
          name: config[:database],
          keep: config[:keep_dumps],
          logger: container[:logger]
        )
        container[:factory] = Factory.new(logger: container[:logger])
        container[:database] = config[:database]
        container
      end
    end
  end
end
