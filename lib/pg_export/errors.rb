class PgExport
  class PgExportError < StandardError; end
  class PgRestoreError < PgExportError; end
  class InvalidConfigurationError < PgExportError; end
  class PgDumpError < PgExportError; end
end
