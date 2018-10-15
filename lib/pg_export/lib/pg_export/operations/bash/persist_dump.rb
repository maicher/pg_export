# frozen_string_literal: true

require 'dry/monads/result'
require 'pg_export/import'

class PgExport
  module Operations
    module Bash
      class PersistDump
        include Dry::Monads::Result::Mixin
        include Import['adapters.bash_adapter']

        def call(dump, db_name)
          bash_adapter.pg_restore(dump.file, db_name)
          Success({})
        rescue Adapters::BashAdapter::PgRestoreError => e
          Failure(message: e.to_s)
        end
      end
    end
  end
end
