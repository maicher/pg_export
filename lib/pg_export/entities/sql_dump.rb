class PgExport
  class SqlDump < Dump::Base
    def name
      'Dump'
    end

    def ext
      ''
    end

    def read_chunk
      read(CHUNK_SIZE)
    end
  end
end
