# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class RemoveOldDumpsFromFtp < PlainListener
        def on_step_succeeded(step_name:, args:, value:)
          value[:removed_dumps].each do |filename|
            logger.info("Remove #{filename} from #{value[:ftp_adapter]}")
          end
        end
      end
    end
  end
end
