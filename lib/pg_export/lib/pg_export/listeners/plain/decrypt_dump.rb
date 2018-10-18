# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class DecryptDump < PlainListener
        def on_step_succeeded(step_name:, args:, value:)
          logger.info("Decrypt #{value[:dump]}")
        end
      end
    end
  end
end
