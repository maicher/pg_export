# frozen_string_literal: true

require 'open3'
require 'pg_export/entities/dump'
require 'pg_export/value_objects/dump_file'

class PgExport
  module Repositories
    class GatewayDumpRepository
      def all(database_name:, gateway:)
        gateway.list(database_name).map do |item|
          dump(item[:name], database_name, item[:size])
        end.compact
      end

      def by_database_name(database_name:, gateway:, offset:)
        gateway.list(database_name).drop(offset).map do |item|
          begin
            dump(item[:name], database_name, item[:size])
          rescue ArgumentError
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
