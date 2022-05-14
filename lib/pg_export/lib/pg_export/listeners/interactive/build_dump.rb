# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class BuildDump < InteractiveListener
        def on_step(event)
          @spinner = build_spinner("Dumping database #{event[:value][:database_name]}")
        end

        def on_step_succeeded(event)
          @spinner.success([success, event[:value][:dump]].join(' '))
        end
      end
    end
  end
end
