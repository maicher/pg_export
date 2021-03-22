# frozen_string_literal: true

PgExport::Container.boot :config do
  init do
    require 'logger'
    require 'pg_export/lib/pg_export/types'
    require 'pg_export/configuration'
  end

  start do
    config = PgExport::Configuration.build(ENV)

    formatters = {
      plain: ->(_, _, _, message) { "#{message}\n" },
      muted: ->(*) {},
      timestamped: lambda do |severity, datetime, progname, message|
        "#{datetime} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)}#{progname} #{severity}: #{message}\n"
      end
    }

    register(:logger, memoize: true) do
      Logger.new($stdout, formatter: formatters.fetch(config.logger_format))
    end

    register(:config, memoize: true) { config }
  end
end
