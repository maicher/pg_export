# frozen_string_literal: true

require 'open3'
require 'pg_export/lib/pg_export/entities/dump'
require 'pg_export/import'

class PgExport
  module Factories
    class DumpFactory
      include Import['logger', 'services.bash']

      def from_database(db_name)
        dump = Entities::Dump.new(name: 'Dump', db_name: db_name)
        bash.pg_dump(dump.path, dump.db_name)
        logger.info "Create #{dump}"
        dump
      end
    end
  end
end
