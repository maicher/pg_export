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
      init do
        require 'pg_export/lib/pg_export/operations/encrypt_dump'
        require 'pg_export/lib/pg_export/operations/remove_old_dumps_from_ftp'
        require 'pg_export/lib/pg_export/operations/upload_dump_to_ftp'
      end

      start do
        use :ftp
        register('operations.encrypt_dump') { ::PgExport::Operations::EncryptDump.new }
        register('operations.remove_old_dumps_from_ftp') { ::PgExport::Operations::RemoveOldDumpsFromFtp.new }
        register('operations.upload_dump_to_ftp') { ::PgExport::Operations::UploadDumpToFtp.new }
      end
    end

    load_paths!('lib')
  end
end
