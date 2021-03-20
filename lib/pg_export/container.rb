# frozen_string_literal: true

require 'dry/system/container'
require 'pg_export/lib/pg_export/types'

class PgExport
  class Container < Dry::System::Container
    configure do
      config.root = Pathname(__FILE__).realpath.dirname
      config.name = :pg_export
      config.default_namespace = 'pg_export'
      config.auto_register = %w[lib]
    end

    load_paths!('lib')

    boot(:ftp) do
      init do
        require 'pg_export/lib/pg_export/factories/ftp_gateway_factory'
      end

      start do
        use :config
        register('factories.gateway_factory') { ::PgExport::Factories::FtpGatewayFactory.new }
      end
    end

    boot(:ssh) do
      init do
        require 'pg_export/lib/pg_export/factories/ssh_gateway_factory'
      end

      start do
        use :config
        register('factories.gateway_factory') { ::PgExport::Factories::SshGatewayFactory.new }
      end
    end

    boot(:main) do |system|
      init do
        require 'pg_export/lib/pg_export/operations/encrypt_dump'
        require 'pg_export/lib/pg_export/operations/decrypt_dump'
        require 'pg_export/lib/pg_export/operations/remove_old_dumps_from_ftp'
        require 'pg_export/lib/pg_export/operations/open_connection'
      end

      start do
        use(system[:config].gateway)

        register('operations.encrypt_dump') { ::PgExport::Operations::EncryptDump.new }
        register('operations.decrypt_dump') { ::PgExport::Operations::DecryptDump.new }
        register('operations.remove_old_dumps_from_ftp') { ::PgExport::Operations::RemoveOldDumpsFromFtp.new }
        register('operations.open_connection') { ::PgExport::Operations::OpenConnection.new }
      end
    end
  end
end
