# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class UploadDumpToFtp < PlainListener
        def on_step_succeeded(step_name:, args:, value:)
          logger.info("Upload #{value[:dump]} to #{value[:ftp_adapter]}")
        end
      end
    end
  end
end
