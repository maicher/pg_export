# frozen_string_literal: true

PgExport::Container.boot :logger do
  init do
    require 'pg_export/build_logger'
  end

  start do
    use :config
    register(:logger) { PgExport::BuildLogger.call(stream: $stdout, format: target[:config][:logger_format]) }
  end
end
