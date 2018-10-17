# frozen_string_literal: true

require_relative '../interactive_listener'

class PgExport
  module Listeners
    class Interactive
      class EncryptDump < InteractiveListener
        def on_step(*)
          @spinner = build_spinner('Encrypting')
        end

        def on_step_succeeded(step_name:, args:, value:)
          @spinner.success([success, value[:dump]].join(' '))
        end
      end
    end
  end
end
