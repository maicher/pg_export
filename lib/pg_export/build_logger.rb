# frozen_string_literal: true

require 'logger'

class PgExport
  class BuildLogger
    FORMATS = {
      plain: ->(_, _, _, message) { "#{message}\n" },
      muted: ->(_, _, _, _) {},
      timestamped: lambda do |severity, datetime, progname, message|
        "#{datetime} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)}#{progname} #{severity}: #{message}\n"
      end
    }.freeze

    def self.call(stream:, format:)
      Logger.new(stream).tap do |logger|
        logger.formatter = FORMATS.fetch(format)
      end
    end
  end
end
