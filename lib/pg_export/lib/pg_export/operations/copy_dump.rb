# frozen_string_literal: true

require 'pg_export/import'

class PgExport
  module Operations
    class CopyDump
      include Import['logger']

      def call(from:, to:, cipher:)
        copy(from: from, to: to, cipher: cipher)
        logger.info "Create #{to}"

        self
      end

      private

      def copy(from:, to:, cipher:)
        cipher.reset
        to.open(:write) do |f|
          from.each_chunk do |chunk|
            f << cipher.update(chunk)
          end
          f << cipher.final
        end

        self
      end
    end
  end
end
