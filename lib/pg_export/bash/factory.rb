# frozen_string_literal: true

require 'open3'
require 'pg_export/value_objects/dump'
require 'pg_export/import'

class PgExport
  module Bash
    class Factory
      include Import['logger', 'repositories.bash_repository']

      def build_dump(db_name)
        dump = ValueObjects::Dump.new(name: 'Dump', db_name: db_name)
        bash_repository.get(dump.path, dump.db_name)
        logger.info "Create #{dump}"
        dump
      end
    end
  end
end
