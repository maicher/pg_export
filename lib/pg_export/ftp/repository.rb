# frozen_string_literal: true

require 'pg_export/import'
require 'pg_export/value_objects/dump'

class PgExport
  module Ftp
    class Repository
      include Import['logger', 'ftp_adapter']

      def persist(dump)
        ftp_adapter.persist(dump.path, dump.timestamped_name)
        logger.info "Persist #{dump} #{dump.timestamped_name} to #{ftp_adapter}"
      end

      def get(db_name)
        dump = ValueObjects::Dump.new(name: 'Encrypted Dump', db_name: db_name)
        ftp_adapter.get(dump.path, dump.db_name)
        logger.info "Get #{dump} #{db_name} from #{ftp_adapter}"
        dump
      end

      def remove_old(name, keep)
        find_by_name(name).drop(keep).each do |filename|
          ftp_adapter.delete(filename)
          logger.info "Remove #{filename} from #{ftp_adapter}"
        end
      end

      def find_by_name(name)
        ftp_adapter.list(name + '_*')
      end

      def all
        ftp_adapter.list('*')
      end
    end
  end
end
