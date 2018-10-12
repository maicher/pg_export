# frozen_string_literal: true

require 'open3'
require 'pg_export/dump'
require 'pg_export/import'

class PgExport
  module Bash
    class Factory
      include Import['logger', 'bash_adapter']

      def build_dump(db_name)
        dump = Dump.new(name: 'Dump', db_name: db_name)
        bash_adapter.get(dump.path, dump.db_name)
        logger.info "Create #{dump}"
        dump
      end
    end
  end
end
