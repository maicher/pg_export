# frozen_string_literal: true

require 'pg_export/value_objects/result'

class PgExport
  module Operations
    class RemoveOldDumps
      def initialize(gateway_dump_repository:, keep:)
        @gateway_dump_repository, @keep = gateway_dump_repository, keep
      end

      def name
        :remove_old_dumps
      end

      def call(dump:, gateway:)
        dumps = gateway_dump_repository.by_database_name(
          database_name: dump.database,
          gateway: gateway,
          offset: keep
        )
        dumps.each do |d|
          gateway.delete(d.name)
        end

        ValueObjects::Success.new(removed_dumps: dumps, gateway: gateway)
      end

      private

      attr_reader :gateway_dump_repository, :keep
    end
  end
end
