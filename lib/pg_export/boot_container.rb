require 'dry-container'

require_relative 'build_logger'
require_relative 'ftp/adapter'
require_relative 'ftp/connection'
require_relative 'ftp/repository'
require_relative 'bash/adapter'
require_relative 'bash/repository'
require_relative 'bash/factory'
require_relative 'aes'
require_relative 'services/create_and_export_dump'

class PgExport
  class BootContainer
    class << self
      def call(config)
        container = Dry::Container.new

        boot_logger(container, config)
        boot_aes(container, config)
        boot_ftp(container, config)
        boot_bash(container)
        boot_services(container)

        container
      end

      private

      def boot_logger(container, config)
        container.register(:logger, memoize: true) { BuildLogger.call(stream: $stdout, format: config[:logger_format]) }
      end

      def boot_aes(container, config)
        container.register(:encryptor, memoize: true) { Aes::Encryptor.new(key: config[:dump_encryption_key], logger: container[:logger]) }
        container.register(:decryptor, memoize: true) { Aes::Decryptor.new(key: config[:dump_encryption_key], logger: container[:logger]) }
      end

      def boot_ftp(container, config)
        container.register(:ftp_connection, memoize: true) {
          Ftp::Connection.new(
            host: config[:ftp_host],
            user: config[:ftp_user],
            password: config[:ftp_password],
            logger: container[:logger]
          )
        }
        container.register(:ftp_adapter, memoize: true) { Ftp::Adapter.new(connection: container[:ftp_connection]) }
        container.register(:ftp_repository, memoize: true) { Ftp::Repository.new(adapter: container[:ftp_adapter], logger: container[:logger]) }
      end

      def boot_bash(container)
        container.register(:bash_adapter, memoize: true) { Bash::Adapter.new }
        container.register(:bash_repository, memoize: true) {
          Bash::Repository.new(
            adapter: container[:bash_adapter],
            logger: container[:logger]
          )
        }
        container.register(:bash_factory, memoize: true) {
          Bash::Factory.new(
            adapter: container[:bash_adapter],
            logger: container[:logger]
          )
        }
      end

      def boot_services(container)
        container.register(:create_and_export_dump, memoize: true) {
          Services::CreateAndExportDump.new(
            bash_factory: container[:bash_factory],
            encryptor: container[:encryptor],
            ftp_repository: container[:ftp_repository]
          )
        }
      end
    end
  end
end
