class PgExport
  class Utils
    include Logging

    def initialize(database_name)
      @database_name = database_name
    end

    def create_dump
      dump = PlainDump.new
      Open3.popen3("pg_dump -Fc --file #{dump.path} #{database_name}") do |_, _, err|
        error = err.read
        raise PgDumpError, error unless error.empty?
      end
      logger.info "Create #{dump}"
      dump
    end

    def restore_dump(dump, restore_database_name)
      Open3.popen3("pg_restore -c -d #{restore_database_name} #{dump.path}") do |_, _, err|
        error = err.read
        raise PgRestoreError, error if /FATAL/ =~ error
      end
      logger.info "Restore #{dump}"
      self
    end

    private

    attr_reader :database_name
  end
end
