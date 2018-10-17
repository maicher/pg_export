# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class BuildDump < InteractiveListener
        def on_step(step_name:, args:)
          @spinner = build_spinner("Dumping database #{args.first[:database_name]}")
        end

        def on_step_succeeded(step_name:, args:, value:)
          @spinner.success([success, value[:dump]].join(' '))
        end
      end
    end
  end
end
