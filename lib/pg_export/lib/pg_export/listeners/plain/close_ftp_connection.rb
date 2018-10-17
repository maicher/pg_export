# frozen_string_literal: true

require_relative '../plain_listener'

class PgExport
  module Listeners
    class Plain
      class CloseFtpConnection < PlainListener
        def on_step_succeeded(*)
          logger.info('Close FTP')
        end
      end
    end
  end
end
