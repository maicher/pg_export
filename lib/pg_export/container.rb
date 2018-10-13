# frozen_string_literal: true

require 'dry/system/container'

class PgExport
  class Container < Dry::System::Container
    configure do
      config.root = Pathname(__FILE__).realpath.dirname
      config.name = :pg_export
      config.default_namespace = 'pg_export'
      config.auto_register = %w[lib]
    end

    boot(:config) do
      init do
        require 'pg_export/configuration'
      end

      start do
        register(:config, memoize: true) { Configuration.build(ENV) }
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
      start do
        use :ftp
        register(:ftp_repository) { Ftp::Repository.new }
      end
    end

    load_paths!('lib')
  end
end
