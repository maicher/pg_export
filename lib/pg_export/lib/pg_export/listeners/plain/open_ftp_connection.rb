# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class OpenFtpConnection < PlainListener
        def on_step_succeeded(event)
          logger.info("Connect to #{event[:value][:ftp_gateway]}")
        end
      end
    end
  end
end
