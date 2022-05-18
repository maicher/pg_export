# frozen_string_literal: true

class PgExport
  module ValueObjects
    class Result
      attr_reader :value

      def initialize(value = nil)
        @value = value
      end
    end

    class Success < Result
      def success
        value
      end

      def bind
        yield
      end

      def on_success
        yield value

        self
      end

      def on_failure
        self
      end
    end

    class Failure < Result
      def bind
        self
      end

      def on_success
        self
      end

      def on_failure
        yield value

        self
      end
    end
  end
end
