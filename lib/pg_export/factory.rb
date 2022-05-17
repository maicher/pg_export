# frozen_string_literal: true

class PgExport
  class Factory
    attr_reader :config

    def initialize(config:)
      @config = config
    end

    def gateway_factory
      if config.gateway == :ftp
        require 'pg_export/lib/pg_export/factories/ftp_gateway_factory'

        Factories::FtpGatewayFactory.new(config: config)
      elsif config.gateway == :ssh
        require 'pg_export/lib/pg_export/factories/ssh_gateway_factory'

        Factories::SshGatewayFactory.new(config: config)
      else
        raise ArgumentError, "Unknown gateway #{config.gateway}"
      end
    end

    def transaction
      require 'pg_export/lib/pg_export/operations/encrypt_dump'
      require 'pg_export/lib/pg_export/operations/decrypt_dump'
      require 'pg_export/lib/pg_export/operations/open_connection'
      require 'pg_export/lib/pg_export/factories/cipher_factory'
      require 'pg_export/lib/pg_export/factories/dump_factory'
      require 'pg_export/lib/pg_export/adapters/shell_adapter'
      require 'pg_export/lib/pg_export/repositories/gateway_dump_repository'
      require 'pg_export/lib/pg_export/repositories/gateway_dump_file_repository'

      cipher_factory = Factories::CipherFactory.new(
        encryption_algorithm: config.encryption_algorithm,
        encryption_key: config.encryption_key
      )

      gateway_dump_repository = Repositories::GatewayDumpRepository.new
      gateway_dump_file_repository = Repositories::GatewayDumpFileRepository.new
      open_connection = Operations::OpenConnection.new(gateway_factory: gateway_factory)
      bash_adapter = Adapters::ShellAdapter.new

      encrypt_dump = Operations::EncryptDump.new(cipher_factory: cipher_factory)

      if config.mode == :plain
        require 'pg_export/lib/pg_export/operations/remove_old_dumps'
        require 'pg_export/lib/pg_export/transactions/export_dump'

        remove_old_dumps = Operations::RemoveOldDumps.new(
          gateway_dump_repository: gateway_dump_repository,
          keep: config.keep_dumps
        )

        PgExport::Transactions::ExportDump.new(
          dump_factory: Factories::DumpFactory.new,
          bash_adapter: bash_adapter,
          encrypt_dump: encrypt_dump,
          open_connection: open_connection,
          remove_old_dumps: remove_old_dumps,
          listeners: plain_listeners
        )
      elsif config.mode == :interactive
        require 'pg_export/lib/pg_export/transactions/import_dump_interactively'
        require 'pg_export/lib/pg_export/ui/interactive/input'

        decrypt_dump = Operations::DecryptDump.new(cipher_factory: cipher_factory)

        PgExport::Transactions::ImportDumpInteractively.new(
          input: Ui::Interactive::Input.new,
          bash_adapter: bash_adapter,
          gateway_dump_file_repository: gateway_dump_file_repository,
          gateway_dump_repository: gateway_dump_repository,
          open_connection: open_connection,
          decrypt_dump: decrypt_dump,
          listeners: interactive_listeners
        )
      else
        raise ArgumentError, "Unknown mode #{config.mode}"
      end
    end

    private

    def plain_listeners
      require 'pg_export/lib/pg_export/listeners/plain/prepare_params'
      require 'pg_export/lib/pg_export/listeners/plain/build_dump'
      require 'pg_export/lib/pg_export/listeners/plain/close_connection'
      require 'pg_export/lib/pg_export/listeners/plain/decrypt_dump'
      require 'pg_export/lib/pg_export/listeners/plain/download_dump'
      require 'pg_export/lib/pg_export/listeners/plain/encrypt_dump'
      require 'pg_export/lib/pg_export/listeners/plain/fetch_dumps'
      require 'pg_export/lib/pg_export/listeners/plain/open_connection'
      require 'pg_export/lib/pg_export/listeners/plain/remove_old_dumps'
      require 'pg_export/lib/pg_export/listeners/plain/restore'
      require 'pg_export/lib/pg_export/listeners/plain/upload_dump'

      logger = build_logger(config.logger_format)

      {
        prepare_params: Listeners::Plain::PrepareParams.new(logger: logger),
        build_dump: Listeners::Plain::BuildDump.new(logger: logger),
        encrypt_dump: Listeners::Plain::EncryptDump.new(logger: logger),
        open_connection: Listeners::Plain::OpenConnection.new(logger: logger),
        upload_dump: Listeners::Plain::UploadDump.new(logger: logger),
        remove_old_dumps: Listeners::Plain::RemoveOldDumps.new(logger: logger),
        close_connection: Listeners::Plain::CloseConnection.new(logger: logger)
      }
    end

    def interactive_listeners
      require 'pg_export/lib/pg_export/listeners/interactive/open_connection'
      require 'pg_export/lib/pg_export/listeners/interactive/fetch_dumps'
      require 'pg_export/lib/pg_export/listeners/interactive/select_dump'
      require 'pg_export/lib/pg_export/listeners/interactive/download_dump'
      require 'pg_export/lib/pg_export/listeners/interactive/close_connection'
      require 'pg_export/lib/pg_export/listeners/interactive/decrypt_dump'
      require 'pg_export/lib/pg_export/listeners/interactive/select_database'
      require 'pg_export/lib/pg_export/listeners/interactive/restore'

      {
        open_connection: Listeners::Interactive::OpenConnection.new,
        fetch_dumps: Listeners::Interactive::FetchDumps.new,
        select_dump: Listeners::Interactive::SelectDump.new,
        download_dump: Listeners::Interactive::DownloadDump.new,
        close_connection: Listeners::Interactive::CloseConnection.new,
        decrypt_dump: Listeners::Interactive::DecryptDump.new,
        select_database: Listeners::Interactive::SelectDatabase.new,
        restore: Listeners::Interactive::Restore.new,
      }
    end

    def build_logger(logger_format)
      require 'logger'

      formatters = {
        plain: ->(_, _, _, message) { "#{message}\n" },
        muted: ->(*) {},
        timestamped: lambda do |severity, datetime, progname, message|
          "#{datetime} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)}#{progname} #{severity}: #{message}\n"
        end
      }

      Logger.new($stdout, formatter: formatters.fetch(logger_format))
    end
  end
end
