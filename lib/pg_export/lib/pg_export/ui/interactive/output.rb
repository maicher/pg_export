# frozen_string_literal: true

require 'pg_export/roles/colourable_string'
require 'tty-spinner'

class PgExport
  module Ui
    module Interactive
      class Output
        using Roles::ColourableString

        def opening_ftp_connection
          build_spinner('Opening ftp connection')
        end

        def fetching_dumps
          build_spinner('Fetching dumps')
        end

        def downloading_dump_from_ftp
          build_spinner('Downloading')
        end

        def decrypting_dump
          build_spinner('Decrypting')
        end

        def restoring
          build_spinner('Restoring')
        end

        def success
          '(success)'.green
        end

        def error
          '(error)'.red
        end

        private

        def build_spinner(message)
          TTY::Spinner.new(
            "[:spinner] #{message}...",
            format: :dots,
            success_mark: SUCCESS_MARK,
            error_mark: ERROR_MARK
          ).tap(&:auto_spin)
        end

        SUCCESS_MARK = "\u2713".green.freeze
        ERROR_MARK = "\u00d7".red.freeze
        private_constant :SUCCESS_MARK, :ERROR_MARK
      end
    end
  end
end
