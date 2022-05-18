# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class CloseConnection < InteractiveListener
        def on_step(*)
          @spinner = build_spinner('Closing connection')
        end

        def on_step_succeeded(*)
          @spinner.success(success)
        end
      end
    end
  end
end
