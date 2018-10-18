# frozen_string_literal: true

require 'dry/transaction/operation'
require 'pg_export/import'

class PgExport
  module Operations
    class OpenFtpConnection
      include Dry::Transaction::Operation
      include Import['factories.ftp_adapter_factory']

      def call(inputs)
        ftp_adapter = ftp_adapter_factory.ftp_adapter
        ftp_adapter.open_ftp
        Success(inputs.merge(ftp_adapter: ftp_adapter))
      end
    end
  end
end
