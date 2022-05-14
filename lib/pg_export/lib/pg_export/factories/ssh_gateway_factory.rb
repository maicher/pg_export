# frozen_string_literal: true

require 'pg_export/lib/pg_export/gateways/ssh'

class PgExport
  module Factories
    class SshGatewayFactory
      def initialize(config:)
        @config = config
      end

      def gateway
        ::PgExport::Gateways::Ssh.new(
          host: config.gateway_host,
          user: config.gateway_user,
          password: config.gateway_password
        )
      end

      private

      attr_reader :config
    end
  end
end
