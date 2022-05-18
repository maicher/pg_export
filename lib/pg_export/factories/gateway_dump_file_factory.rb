# frozen_string_literal: true

require 'open3'
require 'pg_export/entities/dump'
require 'pg_export/value_objects/dump_file'

class PgExport
  module Factories
    class GatewayDumpFileFactory
      def by_name(name:, gateway:)
        file = ValueObjects::DumpFile.new
        gateway.get(file, name)

        file
      end
    end
  end
end
