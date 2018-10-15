# frozen_string_literal: true

# auto_register: false

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class UploadDumpToFtp
      include Dry::Transaction::Operation
      include Import['repositories.ftp_dump_repository', 'logger']

      def call(database_name:, dump:)
        ftp_dump_repository.persist(dump)
        logger.info "Persist #{dump} to #{ftp_dump_repository.ftp_adapter}"
        Success(database_name: database_name)
      end
    end
  end
end
