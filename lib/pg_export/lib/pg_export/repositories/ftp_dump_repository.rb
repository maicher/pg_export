# frozen_string_literal: true

require 'open3'
require 'pg_export/import'
require 'pg_export/lib/pg_export/entities/dump'

class PgExport
  module Repositories
    class FtpDumpRepository
      def all(database_name:, ftp_adapter:)
        ftp_adapter.list([database_name, '*'].compact.join('_')).map do |name|
          begin
            dump(name, database_name)
          rescue Dry::Types::ConstraintError
            nil
          end
        end.compact
      end

      private

      def dump(name, database_name)
        Entities::Dump.new(
          name: name,
          database: database_name,
          type: :encrypted
        )
      end
    end
  end
end
