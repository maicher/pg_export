# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class OpenFtpConnection
      include Dry::Transaction::Operation
      include Import['factories.ftp_gateway_factory']

      def call(inputs)
        ftp_gateway = ftp_gateway_factory.ftp_gateway
        ftp_gateway.open_ftp
        Success(inputs.merge(ftp_gateway: ftp_gateway))
      end
    end
  end
end
