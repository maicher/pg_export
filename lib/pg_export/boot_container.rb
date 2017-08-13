require_relative 'build_logger'
require_relative 'ftp/adapter'
require_relative 'ftp/connection'
require_relative 'ftp/repository'
require_relative 'bash/adapter'
require_relative 'bash/repository'
require_relative 'bash/factory'
require_relative 'aes'

class PgExport
  class BootContainer
    class << self
      def call(config)
        container = {}

        boot_logger(container, config)
        boot_aes(container, config)
        boot_ftp(container, config)
        boot_bash(container)

        container
      end

      private

      def boot_logger(container, config)
        container[:logger] = BuildLogger.call(stream: $stdout, format: config[:logger_format])
      end

      def boot_aes(container, config)
        container[:encryptor] = Aes::Encryptor.new(key: config[:dump_encryption_key], logger: container[:logger])
        container[:decryptor] = Aes::Decryptor.new(key: config[:dump_encryption_key], logger: container[:logger])
      end

      def boot_ftp(container, config)
        container[:ftp_connection] = Ftp::Connection.new(
          host: config[:ftp_host],
          user: config[:ftp_user],
          password: config[:ftp_password],
          logger: container[:logger]
        )
        container[:ftp_adapter] = Ftp::Adapter.new(connection: container[:ftp_connection])
        container[:ftp_repository] = Ftp::Repository.new(adapter: container[:ftp_adapter], logger: container[:logger])
      end

      def boot_bash(container)
        container[:bash_adapter] = Bash::Adapter.new
        container[:bash_repository] = Bash::Repository.new(
          adapter: container[:bash_adapter],
          logger: container[:logger]
        )
        container[:bash_factory] = Bash::Factory.new(
          adapter: container[:bash_adapter],
          logger: container[:logger]
        )
      end
    end
  end
end
