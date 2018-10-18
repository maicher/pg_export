# frozen_string_literal: true

PgExport::Container.boot :config do
  init do
    require 'pg_export/configuration'
  end

  start do
    register(:config, memoize: true) { PgExport::Configuration.build(ENV) }
  end
end
