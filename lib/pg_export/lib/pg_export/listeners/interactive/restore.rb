# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class Restore < InteractiveListener
        def on_step(step_name:, args:)
          @spinner = build_spinner("Restoring dump to database #{args.first[:database]}")
        end

        def on_step_succeeded(*)
          @spinner.success(success)
        end
      end
    end
  end
end
