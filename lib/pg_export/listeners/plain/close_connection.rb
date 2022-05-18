# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class CloseConnection < PlainListener
        def on_step_succeeded(*)
          logger.info('Close connection')
        end
      end
    end
  end
end
