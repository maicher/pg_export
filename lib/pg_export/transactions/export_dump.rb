require 'pg_export/version'
require 'pg_export/boot_container'
require 'pg_export/roles/interactive'
require 'pg_export/errors'
require 'pg_export/roles/validatable'

class PgExport
  module Transactions
    class ExportDump
      include Roles::Validatable

      def initialize(config)
        @container = BootContainer.call(config.to_h)
      end

      def call(database_name, keep_dumps)
        container[:create_and_export_dump].call(
          validate_database_name(database_name),
          validate_keep_dumps(keep_dumps)
        )
      end

      private

      attr_reader :container
    end
  end
end
