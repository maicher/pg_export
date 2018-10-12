# frozen_string_literal: true

require 'dry/system/container'

class PgExport
  class Container < Dry::System::Container
    configure do
      config.root = Pathname(__FILE__).realpath.dirname
      config.name = :pg_export
      config.default_namespace = 'pg_export'
    end

    boot(:config) do
      init do
        require 'pg_export/configuration'
      end

      start do
        register(:config, memoize: true) { Configuration.build_from_env }
      end
    end

    boot(:logger) do
      init do
        require 'pg_export/build_logger'
      end

      start do
        use :config
        register(:logger) { BuildLogger.call(stream: $stdout, format: target[:config][:logger_format]) }
      end
    end

    boot(:ftp_connection) do
      init do
        require 'pg_export/ftp/connection'
      end

      start do
        use :config, :logger

        register(:ftp_connection, memoize: true) do
          Ftp::Connection.new(
            host: target[:config][:ftp_host],
            user: target[:config][:ftp_user],
            password: target[:config][:ftp_password],
            logger: logger
          )
        end
      end
    end

    boot(:ftp) do
      init do
        require 'pg_export/ftp/adapter'
        require 'pg_export/ftp/repository'
      end

      start do
        use :ftp_connection
        register(:ftp_adapter) { Ftp::Adapter.new(ftp_connection: target[:ftp_connection]) }
      end
    end

    boot(:main) do
      init do
        require 'pg_export/bash/adapter'
        require 'pg_export/bash/repository'
        require 'pg_export/bash/factory'
        require 'pg_export/aes'

        register(:bash_adapter) { Bash::Adapter.new }
      end

      start do
        use :ftp

        register(:encryptor) { Aes::Encryptor.new(key: target[:config][:dump_encryption_key], logger: target[:logger]) }
        register(:decryptor) { Aes::Decryptor.new(key: target[:config][:dump_encryption_key], logger: target[:logger]) }
        register(:ftp_repository) { Ftp::Repository.new }
        register(:bash_repository) { Bash::Repository.new }
        register(:bash_factory) { Bash::Factory.new }
      end
    end
  end
end
