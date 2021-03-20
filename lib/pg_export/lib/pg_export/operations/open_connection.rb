# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class OpenConnection
      include Dry::Transaction::Operation
      include Import['factories.gateway_factory']

      def call(inputs)
        gateway = gateway_factory.gateway
        gateway.open
        Success(inputs.merge(gateway: gateway))
      end
    end
  end
end
