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

        def on_step_failed(step_name:, args:, value:)
          @spinner.error([error, value[:message]].join(' '))
        end
      end
    end
  end
end
