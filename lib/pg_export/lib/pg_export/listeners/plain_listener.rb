# frozen_string_literal: true

# auto_register: false

class PgExport
  module Listeners
    class PlainListener
      def initialize(logger)
        @logger = logger
      end

      def on_step_succeeded(event)
        Array(STEP_SUCCEEDED_MAPPING[event[:step_name]]&.call(event[:value])).each do |m|
          logger.info(m)
        end
      end

      private

      attr_reader :logger

      STEP_SUCCEEDED_MAPPING = {
        build_dump: proc { |dump:| "Dump database #{dump.database} to #{dump}" },
        encrypt_dump: proc { |dump:| "Encrypt #{dump}" },
        open_ftp_connection: proc { |ftp_adapter:, dump:| "Connect to #{ftp_adapter}" },
        upload_dump_to_ftp: proc { |dump:, ftp_adapter:| "Upload #{dump} to #{ftp_adapter}" },
        remove_old_dumps_from_ftp: proc { |removed_dumps:, ftp_adapter:|
          removed_dumps.map { |filename| "Remove #{filename} from #{ftp_adapter}" }
        },
        close_ftp_connection: proc { 'Close FTP' }
      }.freeze

      private_constant :STEP_SUCCEEDED__MAPPING
    end
  end
end
