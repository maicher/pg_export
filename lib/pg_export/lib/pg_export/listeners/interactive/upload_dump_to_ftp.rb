# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class UploadDumpToFtp < InteractiveListener
        def on_step(step_name:, args:)
          @spinner = build_spinner("Uploading #{args.first[:dump]} to #{args.first[:ftp_gateway]}")
        end

        def on_step_succeeded(*)
          @spinner.success(success)
        end
      end
    end
  end
end
