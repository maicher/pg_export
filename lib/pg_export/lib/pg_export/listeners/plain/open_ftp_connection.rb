# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class OpenFtpConnection < PlainListener
        def on_step_succeeded(step_name:, args:, value:)
          logger.info("Connect to #{value[:ftp_adapter]}")
        end
      end
    end
  end
end
