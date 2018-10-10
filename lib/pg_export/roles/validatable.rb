require 'dry-types'

class PgExport
  module Roles
    module Validatable
      include Dry::Types.module

      VALID_NON_EMPTY_STRING = Strict::String.constrained(min_size: 1)
      VALID_POSITIVE_INTEGER = Strict::Integer.constrained(gteq: 0)

      def validate_database_name(database)
        VALID_NON_EMPTY_STRING[database]
      rescue Dry::Types::ConstraintError
        raise ArgumentError, 'The "database" parameter has to be a valid, non-empty string'
      end

      def validate_keep_dumps(keep_dumps)
        VALID_POSITIVE_INTEGER[keep_dumps]
      rescue Dry::Types::ConstraintError
        raise ArgumentError, 'The "keep_dumps" parameter has to be a valid, non-negative integer'
      end
    end
  end
end