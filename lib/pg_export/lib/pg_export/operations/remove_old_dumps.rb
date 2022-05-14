# frozen_string_literal: true

require 'pg_export/lib/pg_export/value_objects/result'

class PgExport
  module Operations
    class RemoveOldDumps
      def initialize(gateway_dump_repository:, config:)
        @gateway_dump_repository, @config = gateway_dump_repository, config
      end

      def call(dump:, gateway:)
        dumps = gateway_dump_repository.by_database_name(
          database_name: dump.database,
          gateway: gateway,
          offset: config.keep_dumps
        )
        dumps.each do |d|
          gateway.delete(d.name)
        end

        ValueObjects::Success.new(removed_dumps: dumps, gateway: gateway)
      end

      private

      attr_reader :gateway_dump_repository, :config
    end
  end
end
