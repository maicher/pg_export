# frozen_string_literal: true

require 'pg_export/lib/pg_export/value_objects/result'

class PgExport
  module Operations
    class OpenConnection
      def initialize(gateway_factory:)
        @gateway_factory = gateway_factory
      end

      def name
        :open_connection
      end

      def call(inputs)
        gateway = gateway_factory.gateway
        gateway.open

        ValueObjects::Success.new(inputs.merge(gateway: gateway))
      end

      private

      attr_reader :gateway_factory
    end
  end
end
