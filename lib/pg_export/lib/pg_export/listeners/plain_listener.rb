# frozen_string_literal: true

class PgExport
  module Listeners
    class PlainListener
      def initialize(logger:)
        @logger = logger
      end

      def on_step(*); end

      def on_step_succeeded(*); end

      def on_step_failed(event)
        logger.info("Error: #{event[:value][:message]}")
      end

      private

      attr_reader :logger
    end
  end
end
