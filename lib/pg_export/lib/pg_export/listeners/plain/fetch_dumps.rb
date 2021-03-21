# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class FetchDumps < PlainListener
        def on_step_succeeded(event)
          logger.info("Fetch dumps (#{event[:value][:dumps].count} items)")
        end
      end
    end
  end
end
