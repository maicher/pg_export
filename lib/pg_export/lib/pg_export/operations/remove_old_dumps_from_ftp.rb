# frozen_string_literal: true

# auto_register: false

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class RemoveOldDumpsFromFtp
      include Dry::Transaction::Operation
      include Import['repositories.ftp_dump_repository', 'logger', 'config']

      def call(database_name:)
        ftp_dump_repository.by_name(database_name).drop(config.keep_dumps).each do |filename|
          ftp_dump_repository.delete(filename)
          logger.info "Remove #{filename} from #{ftp_dump_repository.ftp_adapter}"
        end

        Success({})
      end
    end
  end
end
