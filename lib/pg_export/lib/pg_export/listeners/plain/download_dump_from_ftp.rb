# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class DownloadDumpFromFtp < PlainListener
        def on_step_succeeded(step_name:, args:, value:)
          logger.info("Download #{value[:dump]}")
        end
      end
    end
  end
end
