# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class OpenConnection < InteractiveListener
        def on_step(*)
          @spinner = build_spinner('Opening connection')
        end

        def on_step_succeeded(*)
          @spinner.success(success)
        end
      end
    end
  end
end
