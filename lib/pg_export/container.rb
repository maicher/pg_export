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

    boot(:ftp) do
      init do
        require 'pg_export/lib/pg_export/adapters/ftp_adapter'
      end

      start do
        use :config, :logger

        register(:ftp_adapter) do
          ::PgExport::Adapters::FtpAdapter.new(
            host: target[:config][:ftp_host],
            user: target[:config][:ftp_user],
            password: target[:config][:ftp_password],
            logger: logger
          )
        end
      end
    end

    boot(:main) do
      start do
        use :ftp
      end
    end

    load_paths!('lib')
  end
end
