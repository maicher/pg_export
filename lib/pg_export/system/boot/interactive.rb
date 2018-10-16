# frozen_string_literal: true

PgExport::Container.boot(:interactive) do
  init do
    require 'pg_export/lib/pg_export/transactions/import_dump_interactively'
  end

  start do
    use :main, :config

    transaction = PgExport::Transactions::ImportDumpInteractively.new

    unless target[:config].logger_muted?
      require 'pg_export/lib/pg_export/listeners/interactive_listener'
      require 'pg_export/build_logger'

      logger = PgExport::BuildLogger.call(stream: $stdout, format: target[:config].logger_format)
      listener = PgExport::Listeners::InteractiveListener.new(logger)
      transaction.subscribe(listener)
    end

    register('transactions.import_dump_interactively', memoize: true) { transaction }
  end
end
