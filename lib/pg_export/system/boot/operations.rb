# frozen_string_literal: true

PgExport::Container.boot(:operations) do
  init do
    require 'pg_export/lib/pg_export/operations/encrypt_dump'
    require 'pg_export/lib/pg_export/operations/decrypt_dump'
    require 'pg_export/lib/pg_export/operations/remove_old_dumps'
    require 'pg_export/lib/pg_export/operations/open_connection'
  end

  start do
    register('operations.encrypt_dump') { ::PgExport::Operations::EncryptDump.new }
    register('operations.decrypt_dump') { ::PgExport::Operations::DecryptDump.new }
    register('operations.remove_old_dumps') { ::PgExport::Operations::RemoveOldDumps.new }
    register('operations.open_connection') { ::PgExport::Operations::OpenConnection.new }
  end
end
