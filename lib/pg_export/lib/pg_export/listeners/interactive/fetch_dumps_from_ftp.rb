# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class FetchDumpsFromFtp < InteractiveListener
        def on_step(*)
          @spinner = build_spinner('Fetching dumps')
        end

        def on_step_succeeded(*)
          @spinner.success(success)
        end
      end
    end
  end
end
