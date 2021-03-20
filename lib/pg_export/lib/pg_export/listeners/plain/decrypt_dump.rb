# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class DecryptDump < PlainListener
        def on_step_succeeded(event)
          logger.info("Decrypt #{event[:value][:dump]}")
        end
      end
    end
  end
end
