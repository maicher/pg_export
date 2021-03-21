# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class RemoveOldDumps < InteractiveListener
        def on_step(event)
          @spinner = build_spinner("Checking for old dumps on #{event[:args].first[:gateway]}")
        end

        def on_step_succeeded(event)
          if event[:value][:removed_dumps].any?
            @spinner.success([success, event[:value][:removed_dumps].map { |filename| "    #{filename} removed" }].join("\n"))
          else
            @spinner.success([success, 'nothing to remove'].join(' '))
          end
        end
      end
    end
  end
end
