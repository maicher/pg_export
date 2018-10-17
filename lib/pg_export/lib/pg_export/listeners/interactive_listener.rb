# frozen_string_literal: true

# auto_register: false

require 'pg_export/import'
require 'pg_export/roles/colourable_string'
require 'tty-spinner'

class PgExport
  module Listeners
    class InteractiveListener
      using Roles::ColourableString

      include Import['logger']

      private

      SUCCESS_MARK = "\u2713".green.freeze
      ERROR_MARK = "\u00d7".red.freeze
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
        '(success)'.green
      end

      def error
        '(error)'.red
      end
    end
  end
end
