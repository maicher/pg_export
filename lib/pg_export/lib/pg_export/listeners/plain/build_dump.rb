# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class BuildDump < PlainListener
        def on_step_succeeded(event)
          logger.info("Dump database #{event[:value][:dump].database} to #{event[:value][:dump]}")
        end
      end
    end
  end
end
