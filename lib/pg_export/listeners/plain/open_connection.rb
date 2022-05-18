# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class OpenConnection < PlainListener
        def on_step_succeeded(event)
          logger.info("Connect to #{event[:value][:gateway]}")
        end
      end
    end
  end
end
