class PgExport
  module Ftp
    class Repository
      def initialize(adapter:, logger:)
        @adapter, @logger = adapter, logger
      end

      def persist(dump)
        adapter.persist(dump.path, dump.timestamped_name)
        logger.info "Persist #{dump} #{dump.timestamped_name} to #{adapter}"
      end

      def get(db_name)
        dump = Dump.new(name: 'Encrypted Dump', db_name: db_name)
        adapter.get(dump.path, dump.db_name)
        logger.info "Get #{dump} #{db_name} from #{adapter}"
        dump
      end

      def remove_old(name, keep)
        find_by_name(name).drop(keep).each do |filename|
          adapter.delete(filename)
          logger.info "Remove #{filename} from #{adapter}"
        end
      end

      def find_by_name(name)
        adapter.list(name + '_*')
      end

      def all
        adapter.list('*')
      end

      private

      attr_reader :adapter, :logger
    end
  end
end
