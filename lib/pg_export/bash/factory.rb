require 'open3'
require 'pg_export/dump'

class PgExport
  module Bash
    class Factory
      def initialize(adapter:, logger:)
        @adapter, @logger = adapter, logger
      end

      def build_dump(db_name)
        dump = Dump.new(name: 'Dump', db_name: db_name)
        adapter.get(dump.path, dump.db_name)
        logger.info "Create #{dump}"
        dump
      end

      private

      attr_reader :adapter, :logger
    end
  end
end
