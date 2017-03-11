class PgExport
  module Logging
    FORMAT_PLAIN = ->(_, _, _, message) { "#{message}\n" }
    FORMAT_TIMESTAMPED = ->(severity, datetime, progname, message) { "#{datetime} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)}#{progname} #{severity}: #{message}\n" }
    FORMAT_MUTED = ->(_, _, _, _) {}

    class << self
      def logger
        @logger ||= Logger.new(STDOUT).tap do |logger|
          logger.formatter = FORMAT_PLAIN
        end
      end

      def format_default
        logger.formatter = FORMAT_PLAIN
      end

      def format_timestamped
        logger.formatter = FORMAT_TIMESTAMPED
      end

      def mute
        logger.formatter = FORMAT_MUTED
      end
    end

    def logger
      Logging.logger
    end
  end
end
