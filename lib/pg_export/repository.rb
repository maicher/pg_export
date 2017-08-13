class PgExport
  class Repository
    TIMESTAMP = '_%Y%m%d_%H%M%S'.freeze
    TIMESTAMP_REGEX = '[0-9]{8}_[0-9]{6}'.freeze

    def initialize(adapter:, name:, keep:, logger:)
      @adapter, @name, @keep, @logger = adapter, name, keep, logger
    end

    def upload(dump)
      dump_name = timestamped_name(dump)
      adapter.upload_file(dump.path, dump_name)
      logger.info "Upload #{dump} #{dump_name} to #{adapter}"
    end

    def download(name)
      dump = Dump.new('Encrypted Dump')
      adapter.download_file(dump.path, name)
      logger.info "Download #{dump} #{name} from #{adapter}"
      dump
    end

    def remove_old
      find_by_name(name).drop(keep).each do |filename|
        adapter.delete(filename)
        logger.info "Remove #{filename} from #{adapter}"
      end
    end

    def find_by_name(s)
      adapter.list(s + '_*')
    end

    def all
      adapter.list('*')
    end

    private

    attr_reader :adapter, :name, :keep, :logger

    def timestamped_name(dump)
      name + Time.now.strftime(TIMESTAMP) + dump.ext
    end
  end
end
