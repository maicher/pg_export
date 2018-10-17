# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class Restore < InteractiveListener
        def on_step(*)
          @spinner = build_spinner('Restoring')
        end

        def on_step_succeeded(*)
          @spinner.success(success)
        end

        def on_step_failed(*)
          @spinner.error(error)
        end
      end
    end
  end
end
