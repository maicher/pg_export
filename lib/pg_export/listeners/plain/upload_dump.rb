# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class UploadDump < PlainListener
        def on_step_succeeded(event)
          logger.info("Upload #{event[:value][:dump]} to #{event[:value][:gateway]}")
        end
      end
    end
  end
end
