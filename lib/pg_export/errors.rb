class PgExport
  class DependencyRequiredError < StandardError; end
  class DatabaseDoesNotExistError < StandardError; end
  class DumpFileDoesNotExistError < StandardError; end
  class InvalidConfigurationError < StandardError; end
end
