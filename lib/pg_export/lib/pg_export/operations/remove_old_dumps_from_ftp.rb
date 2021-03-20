# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class RemoveOldDumpsFromFtp
      include Dry::Transaction::Operation
      include Import['repositories.gateway_dump_repository', 'config']

      def call(dump:, gateway:)
        dumps = gateway_dump_repository.by_database_name(
          database_name: dump.database,
          gateway: gateway,
          offset: config.keep_dumps
        )
        dumps.each do |d|
          gateway.delete(d.name)
        end

        Success(removed_dumps: dumps, gateway: gateway)
      end
    end
  end
end
