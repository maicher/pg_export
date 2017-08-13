require 'open3'
require 'pg_export/dump'

class PgExport
  class PgDumpError < StandardError; end

  class Factory
    def initialize(logger:)
      @logger = logger
    end

    def build_dump(database_name)
      dump = Dump.new('Dump')
      Open3.popen3("pg_dump -Fc --file #{dump.path} #{database_name}") do |_, _, err|
        error = err.read
        raise PgDumpError, error unless error.empty?
      end
      logger.info "Create #{dump}"
      dump
    end

    private

    attr_reader :logger
  end
end