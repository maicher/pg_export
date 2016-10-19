class PgExport
  class RemoveOldDumps
    include Logging

    def initialize(dump, keep_dumps_count)
      @dump = dump
      @keep_dumps_count = keep_dumps_count.to_i
    end

    def call
      files.sort.reverse.drop(keep_dumps_count).each do |filename|
        File.delete("#{dump.dirname}/#{filename}")
        logger.info "Remove file #{filename}"
      end
    end

    private

    attr_reader :dump, :keep_dumps_count

    def files
      Dir.entries(dump.dirname).grep(dump.regexp)
    end
  end
end
