# frozen_string_literal: true

# auto_register: false

require 'pg_export/roles/colourable_string'

class PgExport
  module Listeners
    class InteractiveListener
      using Roles::ColourableString

      def initialize(logger)
        @logger = logger
      end

      def on_step(event)
        Array(STEP_MAPPING[event[:step_name]]&.call(event[:args].first)).each do |m|
          logger.info(m)
        end
      end

      def on_step_succeeded(event)
        Array(STEP_SUCCEEDED__MAPPING[event[:step_name]]&.call(event[:value])).each do |m|
          logger.info(m)
        end
      end

      private

      attr_reader :logger

      STEP_MAPPING = {
        open_ftp_connection: proc do
          puts 'Interactive mode, for restoring dump into database.'.green
        end
      }.freeze

      STEP_SUCCEEDED__MAPPING = {}.freeze

      private_constant :STEP_MAPPING, :STEP_SUCCEEDED__MAPPING
    end
  end
end
