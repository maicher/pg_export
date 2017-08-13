require 'open3'

class PgExport
    class PgRestoreError < StandardError; end

  class BashUtils
    def initialize(database_name:, logger:)
      @database_name = database_name
      @logger = logger
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

    attr_reader :database_name, :logger
  end
end
