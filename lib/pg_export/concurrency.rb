class PgExport
  module Concurrency
    class ThreadsArray < Array
      def <<(job)
        super Thread.new { job }
      end

      alias push <<
    end

    def self.included(*)
      Thread.abort_on_exception = true
    end

    def concurrently
      t = ThreadsArray.new
      yield t
      t.each(&:join)
    end
  end
end
