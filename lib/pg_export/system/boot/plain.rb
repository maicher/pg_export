# frozen_string_literal: true

PgExport::Container.boot(:plain) do
  init do
    require 'pg_export/lib/pg_export/transactions/export_dump'
  end

  start do
    use :main

    transaction = PgExport::Transactions::ExportDump.new

    unless target[:config].logger_muted?
      use :logger

      %i[
        build_dump
        encrypt_dump
        open_ftp_connection
        upload_dump_to_ftp
        remove_old_dumps_from_ftp
        close_ftp_connection
      ].each do |step|
        transaction.subscribe(step => target["listeners.plain.#{step}"])
      end
    end

    register('transactions.export_dump', memoize: true) { transaction }
  end
end
