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

        register('factories.gateway_factory') do
          ::PgExport::Factories::FtpGatewayFactory.new
        end
      end
    end

    boot(:main) do
      init do
        require 'pg_export/lib/pg_export/operations/encrypt_dump'
        require 'pg_export/lib/pg_export/operations/decrypt_dump'
        require 'pg_export/lib/pg_export/operations/remove_old_dumps_from_ftp'
        require 'pg_export/lib/pg_export/operations/open_ftp_connection'
      end

      start do
        use :ftp
        register('operations.encrypt_dump') { ::PgExport::Operations::EncryptDump.new }
        register('operations.decrypt_dump') { ::PgExport::Operations::DecryptDump.new }
        register('operations.remove_old_dumps_from_ftp') { ::PgExport::Operations::RemoveOldDumpsFromFtp.new }
        register('operations.open_ftp_connection') { ::PgExport::Operations::OpenFtpConnection.new }
      end
    end
  end
end
