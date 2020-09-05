# frozen_string_literal: true

require 'dry-types'
require 'pg_export/lib/pg_export/value_objects/dump_file'

class PgExport
  module Types
    include Dry::Types()

    DumpName = Strict::String.constrained(format: /.+_20[0-9]{6}_[0-9]{6}\Z/)
    DumpType = Types::Coercible::String.enum('plain', 'encrypted')
    DumpFile = Types.Instance(PgExport::ValueObjects::DumpFile)
  end
end
