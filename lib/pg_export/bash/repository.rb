# frozen_string_literal: true

require 'dry/monads/result'

class PgExport
  module Bash
    class Repository
      include Dry::Monads::Result::Mixin

      def initialize(adapter:, logger:)
        @adapter, @logger = adapter, logger
      end

      def persist(dump, db_name)
        adapter.persist(dump.path, db_name)
        logger.info "Persist #{dump} #{db_name} to #{adapter}"
        return Success({})
      rescue Adapter::PgPersistError => e
        return Failure(e.to_s)
      end

      private

      attr_reader :adapter, :logger
    end
  end
end
