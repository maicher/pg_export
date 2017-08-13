require_relative 'build_logger'
require_relative 'ftp/adapter'
require_relative 'ftp/connection'
require_relative 'bash/adapter'
require_relative 'repository'
require_relative 'factory'
require_relative 'aes'

class PgExport
  class BootContainer
    class << self
      def call(config)
        container = {}
        container[:logger] = BuildLogger.call(stream: $stdout, format: config[:logger_format])

        container[:encryptor] = Aes::Encryptor.new(key: config[:dump_encryption_key], logger: container[:logger])
        container[:decryptor] = Aes::Decryptor.new(key: config[:dump_encryption_key], logger: container[:logger])

        container[:ftp_connection] = Ftp::Connection.new(
          host: config[:ftp_host],
          user: config[:ftp_user],
          password: config[:ftp_password],
          logger: container[:logger]
        )
        container[:ftp_adapter] = Ftp::Adapter.new(connection: container[:ftp_connection])
        container[:ftp_repository] = Repository.new(
          adapter: container[:ftp_adapter],
          logger: container[:logger]
        )

        container[:bash_adapter] = Bash::Adapter.new
        container[:bash_repository] = Repository.new(
          adapter: container[:bash_adapter],
          logger: container[:logger]
        )

        container[:factory] = Factory.new(
          adapter: container[:bash_adapter],
          logger: container[:logger]
        )

        container
      end
    end
  end
end
