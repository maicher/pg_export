# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class PrepareParams < PlainListener
        def on_step_succeeded(event)
          logger.info("Init")
        end
      end
    end
  end
end
