# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class Restore < PlainListener
        def on_step_succeeded(event)
          logger.info("Restore dump to database #{args.first[:database]}")
        end
      end
    end
  end
end
