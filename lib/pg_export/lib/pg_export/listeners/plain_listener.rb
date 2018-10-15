# frozen_string_literal: true

# auto_register: false

class PgExport
  module Listeners
    class PlainListener
      def initialize(logger)
        @logger = logger
      end

      MAPPING = {
        build_dump: ->(args) { "Created #{args[:dump]}" },
        encrypt_dump: ->(args) { "Created #{args[:dump]}" },
        open_ftp_connection: ->(args) { "Connected to #{args[:ftp_adapter]}" },
        upload_dump_to_ftp: ->(args) { "Uploaded #{args[:dump]} to #{args[:ftp_adapter]}" },
        remove_old_dumps_from_ftp: ->(args) { args[:removed_dumps].map { |filename| "Removed #{filename} from #{args[:ftp_adapter]}" } },
        close_ftp_connection: ->(args) { "Closed #{args[:ftp_adapter]}" }
      }.freeze

      def on_step_succeeded(event)
        Array(MAPPING[event[:step_name]]&.call(event[:value])).each do |m|
          logger.info(m)
        end
      end

      private

      attr_reader :logger
    end
  end
end
