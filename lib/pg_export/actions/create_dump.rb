class PgExport
  class CreateDump
    include Logging

    def initialize(dump)
      @dump = dump
    end

    def call
      validate_pg_dump_exists
      validate_db_exists(dump.database)
      execute_dump_command
      logger.info "Dump #{dump.database} to #{dump.pathname} (#{dump.size})"
    end

    private

    attr_reader :dump

    def validate_pg_dump_exists
      out = `pg_dump -V`
      /pg_dump \(PostgreSQL\)/ =~ out or raise DependencyRequiredError, 'pg_dump is required'
    end

    def validate_db_exists(database)
      PG.connect(dbname: database)
    rescue PG::ConnectionBad => e
      raise DatabaseDoesNotExistError, e.to_s
    end

    def execute_dump_command
      `pg_dump -Fc --file #{dump.pathname} #{dump.database}`
    end
  end
end
