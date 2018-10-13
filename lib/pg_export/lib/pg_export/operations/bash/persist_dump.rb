# frozen_string_literal: true

require 'dry/monads/result'
require 'pg_export/import'

class PgExport
  module Operations
    module Bash
      class PersistDump
        include Dry::Monads::Result::Mixin
        include Import['logger', 'repositories.bash_repository']

        def call(dump, db_name)
          bash_repository.persist(dump.path, db_name)
          logger.info "Persist #{dump} #{db_name} to #{bash_repository}"
          Success({})
        rescue bash_repository.class::PgPersistError => e
          Failure(message: e.to_s)
        end
      end
    end
  end
end
