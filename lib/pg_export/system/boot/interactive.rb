# frozen_string_literal: true

PgExport::Container.boot(:interactive) do
  init do
    require 'pg_export/lib/pg_export/transactions/import_dump_interactively'
  end

  start do
    type = 'interactive'
    transaction = PgExport::Transactions::ImportDumpInteractively.new(ui_input: target["ui.#{type}.input"])

    unless target[:config].logger_muted?
      %i[
        open_connection
        fetch_dumps
        download_dump
        decrypt_dump
        restore
      ].each do |step|
        transaction.subscribe(step => target["listeners.#{type}.#{step}"])
      end
    end

    register('transaction', memoize: true) { transaction }
  end
end
