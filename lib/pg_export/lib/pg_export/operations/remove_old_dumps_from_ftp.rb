# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class RemoveOldDumpsFromFtp
      include Dry::Transaction::Operation
      include Import['repositories.ftp_dump_repository', 'config']

      def call(dump:, ftp_adapter:)
        dumps = ftp_adapter.list(dump.database + '_*').drop(config.keep_dumps)
        dumps.each do |filename|
          ftp_adapter.delete(filename)
        end

        Success(removed_dumps: dumps, ftp_adapter: ftp_adapter)
      end
    end
  end
end
