# frozen_string_literal: true

class PgExport
  class PgExportError < StandardError; end
  class PgRestoreError < PgExportError; end
  class PgDumpError < PgExportError; end
end
