class PgExport
  class SqlDump < Dump::Base
    def name
      'Dump'
    end

    def ext
      ''
    end

    def open(operation_type, &block)
      case operation_type.to_sym
        when :read then File.open(path, 'r', &block)
        when :write then File.open(path, 'w', &block)
        else raise ArgumentError, 'Operation type can be only :read or :write'
      end
    end
  end
end
