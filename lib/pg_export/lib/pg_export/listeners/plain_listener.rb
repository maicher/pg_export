# frozen_string_literal: true

# auto_register: false

class PgExport
  module Listeners
    class PlainListener
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
        build_dump: proc { |database_name:| "Dumping database #{database_name}.." },
        open_ftp_connection: proc { 'Opening ftp connection..' },
        upload_dump_to_ftp: proc { |dump:, ftp_adapter:| "Uploading #{dump} to #{ftp_adapter}.." },
        close_ftp_connection: proc { 'Closing ftp connection..' }
      }.freeze

      STEP_SUCCEEDED__MAPPING = {
        build_dump: proc { |dump:| "Dumped #{dump}" },
        encrypt_dump: proc { |dump:| "Created #{dump}" },
        open_ftp_connection: proc { |ftp_adapter:, dump:| "Connected to #{ftp_adapter}" },
        upload_dump_to_ftp: proc { 'Uploaded' },
        remove_old_dumps_from_ftp: proc { |removed_dumps:, ftp_adapter:|
          removed_dumps.map { |filename| "Removed #{filename} from #{ftp_adapter}" }
        },
        close_ftp_connection: proc { |ftp_adapter:| "Closed #{ftp_adapter}" }
      }.freeze

      private_constant :STEP_MAPPING, :STEP_SUCCEEDED__MAPPING
    end
  end
end
