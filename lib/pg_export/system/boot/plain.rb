# frozen_string_literal: true

PgExport::Container.boot(:plain) do
  init do
    require 'pg_export/lib/pg_export/transactions/export_dump'
  end

  start do
    transaction = PgExport::Transactions::ExportDump.new
    transaction.steps.each do |step|
      transaction.subscribe(step.name => target["listeners.plain.#{step.name}"])
    end

    register('transaction', memoize: true) { transaction }
  end
end
