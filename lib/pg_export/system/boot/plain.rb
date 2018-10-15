# frozen_string_literal: true

PgExport::Container.boot(:plain) do
  init do
    require 'pg_export/lib/pg_export/transactions/export_dump'
  end

  start do
    use :main, :config

    transaction = PgExport::Transactions::ExportDump.new

    unless target[:config].logger_muted?
      require 'pg_export/lib/pg_export/listeners/plain_listener'
      require 'pg_export/build_logger'

      logger = PgExport::BuildLogger.call(stream: $stdout, format: target[:config].logger_format)
      listener = PgExport::Listeners::PlainListener.new(logger)
      transaction.subscribe(listener)
    end

    register('transactions.export_dump', memoize: true) { transaction }
  end
end
