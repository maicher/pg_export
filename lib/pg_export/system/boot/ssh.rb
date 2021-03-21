# frozen_string_literal: true

PgExport::Container.boot(:ssh) do
  init do
    require 'pg_export/lib/pg_export/factories/ssh_gateway_factory'
  end

  start do
    register('factories.gateway_factory') { ::PgExport::Factories::SshGatewayFactory.new }
  end
end
