# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class DecryptDump < InteractiveListener
        def on_step(*)
          @spinner = build_spinner('Decrypting')
        end

        def on_step_succeeded(event)
          @spinner.success([success, event[:value][:dump]].join(' '))
        end
      end
    end
  end
end
