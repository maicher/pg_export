# frozen_string_literal: true

PgExport::Container.boot(:ftp) do
  init do
    require 'pg_export/lib/pg_export/factories/ftp_gateway_factory'
  end

  start do
    register('factories.gateway_factory') { ::PgExport::Factories::FtpGatewayFactory.new }
  end
end
