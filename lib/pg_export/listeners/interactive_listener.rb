# frozen_string_literal: true

require 'tty-spinner'

class PgExport
  module Listeners
    class InteractiveListener
      def on_step(*); end

      def on_step_succeeded(*); end

      def on_step_failed(event)
        @spinner.error([error, self.class.red(event[:value][:message])].join("\n"))
      end

      class << self
        def green(s)
          "\e[0;32;49m#{s}\e[0m"
        end

        def red(s)
          "\e[31m#{s}\e[0m"
        end
      end

      private

      SUCCESS_MARK = green("\u2713").freeze
      ERROR_MARK = red("\u00d7").freeze
      private_constant :SUCCESS_MARK, :ERROR_MARK

      def build_spinner(message)
        TTY::Spinner.new(
          "[:spinner] #{message}...",
          format: :dots,
          success_mark: SUCCESS_MARK,
          error_mark: ERROR_MARK
        ).tap(&:auto_spin)
      end

      def success
        self.class.green('(success)')
      end

      def error
        self.class.red('(error)')
      end
    end
  end
end
