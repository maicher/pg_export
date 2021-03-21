# frozen_string_literal: true

PgExport::Container.boot(:plain) do
  init do
    require 'pg_export/lib/pg_export/transactions/export_dump'
  end

  start do
    transaction = PgExport::Transactions::ExportDump.new

    unless target[:config].logger_muted?
      use :logger

      type = 'plain'
      %i[
        build_dump
        encrypt_dump
        open_connection
        upload_dump_to_ftp
        remove_old_dumps_from_ftp
        close_connection
      ].each do |step|
        transaction.subscribe(step => target["listeners.#{type}.#{step}"])
      end
    end

    register('transaction', memoize: true) { transaction }
  end
end
