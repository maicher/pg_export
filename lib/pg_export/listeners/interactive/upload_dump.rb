# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class UploadDump < InteractiveListener
        def on_step(event)
          @spinner = build_spinner("Uploading #{event[:value][:dump]} to #{event[:value][:gateway]}")
        end

        def on_step_succeeded(*)
          @spinner.success(success)
        end
      end
    end
  end
end
