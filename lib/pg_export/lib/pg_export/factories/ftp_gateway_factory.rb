# frozen_string_literal: true

# auto_register: false

require 'pg_export/lib/pg_export/gateways/ftp'
require 'pg_export/import'

class PgExport
  module Factories
    class FtpGatewayFactory
      include Import['config']

      def ftp_gateway
        ::PgExport::Gateways::Ftp.new(
          host: config.ftp_host,
          user: config.ftp_user,
          password: config.ftp_password
        )
      end
    end
  end
end
