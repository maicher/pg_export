# frozen_string_literal: true

class PgExport
  module Bash
    class Repository
      def initialize(adapter:, logger:)
        @adapter, @logger = adapter, logger
      end

      def persist(dump, db_name)
        adapter.persist(dump.path, db_name)
        logger.info "Persist #{dump} #{db_name} to #{adapter}"
      end

      private

      attr_reader :adapter, :logger
    end
  end
end
