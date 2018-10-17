# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class FetchDumpsFromFtp < PlainListener
        def on_step_succeeded(step_name:, args:, value:)
          logger.info("Fetch dumps (#{value[:dumps].count} items)")
        end

        def on_step_failed(step_name:, args:, value:)
          logger.info("Error: #{value[:message]}")
        end
      end
    end
  end
end
