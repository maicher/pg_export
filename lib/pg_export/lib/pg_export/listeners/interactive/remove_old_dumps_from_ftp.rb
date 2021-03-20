# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class RemoveOldDumpsFromFtp < InteractiveListener
        def on_step(step_name:, args:)
          @spinner = build_spinner("Checking for old dumps on #{args.first[:ftp_adapter]}")
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
