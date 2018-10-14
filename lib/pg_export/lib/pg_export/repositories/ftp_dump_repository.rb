# frozen_string_literal: true

require 'open3'
require 'pg_export/lib/pg_export/entities/dump'

class PgExport
  module Repositories
    class FtpDumpRepository
      include Import['ftp_adapter']

      def get(db_name)
        dump = Entities::Dump.new(name: 'Encrypted Dump', db_name: db_name)
        ftp_adapter.get(dump.path, dump.db_name)
        dump
      end

      def persist(dump)
        ftp_adapter.persist(dump.path, dump.timestamped_name)

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
