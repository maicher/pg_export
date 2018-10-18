# frozen_string_literal: true

require 'open3'
require 'pg_export/import'
require 'pg_export/lib/pg_export/entities/dump'
require 'pg_export/lib/pg_export/value_objects/dump_file'

class PgExport
  module Repositories
    class FtpDumpFileRepository
      def by_name(name:, ftp_adapter:)
        file = ValueObjects::DumpFile.new
        ftp_adapter.get(file, name)

        file
      end
    end
  end
end
