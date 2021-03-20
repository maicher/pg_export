# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class UploadDumpToFtp < PlainListener
        def on_step_succeeded(event)
          logger.info("Upload #{event[:value][:dump]} to #{event[:value][:ftp_gateway]}")
        end
      end
    end
  end
end
