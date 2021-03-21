# frozen_string_literal: true

PgExport::Container.boot(:plain) do
  init do
    require 'pg_export/lib/pg_export/transactions/export_dump'
  end

  start do
    transaction = PgExport::Transactions::ExportDump.new

    unless target[:config].logger_muted?
      type = 'plain'
      %i[
        build_dump
        encrypt_dump
        open_connection
        upload_dump
        remove_old_dumps
        close_connection
      ].each do |step|
        transaction.subscribe(step => target["listeners.#{type}.#{step}"])
      end
    end

    register('transaction', memoize: true) { transaction }
  end
end
