# frozen_string_literal: true

PgExport::Container.boot(:interactive) do
  init do
    require 'pg_export/lib/pg_export/transactions/import_dump_interactively'
  end

  start do
    use :main

    # type = 'plain'
    type = 'interactive'

    transaction = PgExport::Transactions::ImportDumpInteractively.new(ui_input: target["ui.#{type}.input"])

    unless target[:config].logger_muted?
      use :logger

      %i[
        open_ftp_connection
        fetch_dumps_from_ftp
        download_dump_from_ftp
        decrypt_dump
        restore
      ].each do |step|
        transaction.subscribe(step => target["listeners.#{type}.#{step}"])
      end
    end

    register('transactions.import_dump_interactively', memoize: true) { transaction }
  end
end
