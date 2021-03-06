# frozen_string_literal: true

require 'open3'
require 'pg_export/import'
require 'pg_export/lib/pg_export/entities/dump'
require 'pg_export/lib/pg_export/value_objects/dump_file'

class PgExport
  module Repositories
    class FtpDumpRepository
      def all(database_name:, ftp_adapter:)
        ftp_adapter.list([database_name, '*'].compact.join('_')).map do |name:, size:|
          begin
            dump(name, database_name, size)
          rescue Dry::Types::ConstraintError
            nil
          end
        end.compact
      end

      def by_database_name(database_name:, ftp_adapter:, offset:)
        ftp_adapter.list(database_name + '_*').drop(offset).map do |name:, size:|
          begin
            dump(name, database_name, size)
          rescue Dry::Types::ConstraintError
            nil
          end
        end.compact
      end

      private

      FilePlaceholder = Struct.new(:size)
      private_constant :FilePlaceholder

      def dump(name, database_name, size)
        Entities::Dump.new(
          name: name,
          database: database_name,
          file: ValueObjects::DumpFile.new(FilePlaceholder.new(size.to_i)),
          type: :encrypted
        )
      end
    end
  end
end
