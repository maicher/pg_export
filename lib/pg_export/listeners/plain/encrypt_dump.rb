# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class EncryptDump < PlainListener
        def on_step_succeeded(event)
          logger.info("Encrypt #{event[:value][:dump]}")
        end
      end
    end
  end
end
