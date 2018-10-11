# frozen_string_literal: true

require 'dry-container'

require_relative 'build_logger'
require_relative 'ftp/adapter'
require_relative 'ftp/connection'
require_relative 'ftp/repository'
require_relative 'bash/adapter'
require_relative 'bash/repository'
require_relative 'bash/factory'
require_relative 'aes'

class PgExport
  class InitializationError < StandardError; end

  class BootContainer
    class << self
      def call
        config = Configuration.new(
          dump_encryption_key: ENV['DUMP_ENCRYPTION_KEY'],
          ftp_host: ENV['BACKUP_FTP_HOST'],
          ftp_user: ENV['BACKUP_FTP_USER'],
          ftp_password: ENV['BACKUP_FTP_PASSWORD'],
          logger_format: ENV['LOGGER_FORMAT']
        )
        container = Dry::Container.new

        boot_logger(container, config)
        boot_aes(container, config)
        boot_ftp(container, config)
        boot_bash(container)

        container
      rescue Dry::Struct::Error => e
        raise PgExport::InitializationError, e
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
        container.register(:ftp_connection, memoize: true) do
          Ftp::Connection.new(
            host: config[:ftp_host],
            user: config[:ftp_user],
            password: config[:ftp_password],
            logger: container[:logger]
          )
        end
        container.register(:ftp_adapter, memoize: true) { Ftp::Adapter.new(connection: container[:ftp_connection]) }
        container.register(:ftp_repository, memoize: true) { Ftp::Repository.new(adapter: container[:ftp_adapter], logger: container[:logger]) }
      end

      def boot_bash(container)
        container.register(:bash_adapter, memoize: true) { Bash::Adapter.new }
        container.register(:bash_repository, memoize: true) do
          Bash::Repository.new(
            adapter: container[:bash_adapter],
            logger: container[:logger]
          )
        end
        container.register(:bash_factory, memoize: true) do
          Bash::Factory.new(
            adapter: container[:bash_adapter],
            logger: container[:logger]
          )
        end
      end
    end
  end
end
