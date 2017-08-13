class PgExport
  class Repository
    def initialize(adapter:, logger:)
      @adapter, @logger = adapter, logger
    end

    def persist(dump, db_name = nil)
      name = db_name || dump.timestamped_name
      adapter.persist(dump.path, name)
      logger.info "Persist #{dump} #{name} to #{adapter}"
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
