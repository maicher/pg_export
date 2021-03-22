# frozen_string_literal: true

PgExport::Container.boot(:interactive) do
  init do
    require 'pg_export/lib/pg_export/transactions/import_dump_interactively'
  end

  start do
    transaction = PgExport::Transactions::ImportDumpInteractively.new
    transaction.steps.each do |step|
      transaction.subscribe(step.name => target["listeners.interactive.#{step.name}"])
    end

    register('transaction', memoize: true) { transaction }
  end
end
