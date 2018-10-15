# frozen_string_literal: true

require 'open3'
require 'pg_export/import'
require 'pg_export/lib/pg_export/entities/dump'
require 'pg_export/lib/pg_export/value_objects/dump_file'

class PgExport
  module Repositories
    class FtpDumpRepository
      include Import['ftp_adapter']

      def get(name)
        file = ValueObjects::DumpFile.new
        ftp_adapter.get(file, name)

        Entities::Dump.new(
          name: name,
          database: '???',
          file: file,
          type: :encrypted
        )
      end

      def persist(dump)
        ftp_adapter.persist(dump.file, dump.name)

        self
      end

      def by_name(name)
        ftp_adapter.list(name + '_*')
      end

      def all
        ftp_adapter.list('*')
      end

      def delete(filename)
        ftp_adapter.delete(filename)
      end
    end
  end
end
