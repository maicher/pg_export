# frozen_string_literal: true

require 'open3'
require 'tempfile'

require 'pg_export/lib/pg_export/entities/dump'

class PgExport
  module Factories
    class DumpFactory
      def plain(database:, file:)
        Entities::Dump.new(
          name: [database, timestamp].join('_'),
          database: database,
          file: file,
          type: :plain
        )
      end

      private

      TIMESTAMP_FORMAT = '%Y%m%d_%H%M%S'
      private_constant :TIMESTAMP_FORMAT

      def timestamp
        Time.now.strftime(TIMESTAMP_FORMAT)
      end
    end
  end
end
