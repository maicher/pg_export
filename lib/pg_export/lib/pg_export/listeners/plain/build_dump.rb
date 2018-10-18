# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class BuildDump < PlainListener
        def on_step_succeeded(step_name:, args:, value:)
          logger.info("Dump database #{value[:dump].database} to #{value[:dump]}")
        end
      end
    end
  end
end
