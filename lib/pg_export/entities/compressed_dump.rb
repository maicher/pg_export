class PgExport
  class CompressedDump < Dump::Base
    def name
      'Compressed Dump'
    end

    def ext
      '.gz'
    end

    def open(operation_type, &block)
      case operation_type.to_sym
        when :read then Zlib::GzipReader.open(path, &block)
        when :write then Zlib::GzipWriter.open(path, &block)
        else raise ArgumentError, 'Operation type can be only :read or :write'
      end
    end
  end
end
