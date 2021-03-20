# frozen_string_literal: true

# auto_register: false

require 'pg_export/lib/pg_export/gateways/ssh'
require 'pg_export/import'

class PgExport
  module Factories
    class SshGatewayFactory
      include Import['config']

      def gateway
        ::PgExport::Gateways::Ssh.new(
          host: config.gateway_host,
          user: config.gateway_user,
          password: config.gateway_password
        )
      end
    end
  end
end
