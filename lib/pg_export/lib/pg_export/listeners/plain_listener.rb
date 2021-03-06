# frozen_string_literal: true

# auto_register: false

require 'pg_export/import'

class PgExport
  module Listeners
    class PlainListener
      include Import['logger']

      def on_step_failed(step_name:, args:, value:)
        logger.info("Error: #{value[:message]}")
      end
    end
  end
end
