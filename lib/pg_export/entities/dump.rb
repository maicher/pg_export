class PgExport
  class Dump
    extend Forwardable
    include SizeHuman

    CHUNK_SIZE = (2**16).freeze

    def_delegators :file, :path, :read, :write, :<<, :rewind, :close, :size, :eof?

    attr_reader :name

    def initialize(name)
      @name = name
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

    def each_chunk
      open(:read) do |file|
        yield file.read(CHUNK_SIZE) until file.eof?
      end
    end

    def to_s
      "#{name} (#{size_human})"
    end

    private

    def file
      @file ||= Tempfile.new(file_name)
    end

    def file_name
      name.downcase.gsub(/[^0-9a-z]/, '_')
    end
  end
end