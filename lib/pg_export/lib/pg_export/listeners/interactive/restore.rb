# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class Restore < InteractiveListener
        def on_step(event)
          @spinner = build_spinner("Restoring dump to database #{event[:value][:database]}")
        end

        def on_step_succeeded(*)
          @spinner.success(success)
        end
      end
    end
  end
end
