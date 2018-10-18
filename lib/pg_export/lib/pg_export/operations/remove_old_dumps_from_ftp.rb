# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class RemoveOldDumpsFromFtp
      include Dry::Transaction::Operation
      include Import['repositories.ftp_dump_repository', 'config']

      def call(dump:, ftp_adapter:)
        dumps = ftp_dump_repository.by_database_name(
          database_name: dump.database,
          ftp_adapter: ftp_adapter,
          offset: config.keep_dumps
        )
        dumps.each do |d|
          ftp_adapter.delete(d.name)
        end

        Success(removed_dumps: dumps, ftp_adapter: ftp_adapter)
      end
    end
  end
end
