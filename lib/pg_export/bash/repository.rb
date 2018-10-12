# frozen_string_literal: true

require 'dry/monads/result'
require 'pg_export/import'

class PgExport
  module Bash
    class Repository
      include Dry::Monads::Result::Mixin
      include Import['logger', 'bash_adapter']

      def persist(dump, db_name)
        bash_adapter.persist(dump.path, db_name)
        logger.info "Persist #{dump} #{db_name} to #{bash_adapter}"
        Success({})
      rescue bash_adapter::PgPersistError => e
        Failure(e.to_s)
      end
    end
  end
end
