# frozen_string_literal: true

require 'dry/monads/result'
require 'pg_export/import'

class PgExport
  module Operations
    module Bash
      class PersistDump
        include Dry::Monads::Result::Mixin
        include Import['logger', 'services.bash']

        def call(dump, db_name)
          bash.pg_restore(dump.path, db_name)
          logger.info "Persist #{dump} #{db_name}"
          Success({})
        rescue Services::Bash::PgRestoreError => e
          Failure(message: e.to_s)
        end
      end
    end
  end
end
