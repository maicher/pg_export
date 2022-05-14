# frozen_string_literal: true

require 'pry'

class PgExport
  module ValueObjects
    class Result
      attr_reader :value

      def initialize(value)
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

      def on_step_succeeded
        yield
      end
    end

    class Failure < Result
      def bind
        self
      end

      def on_step_succeeded
      end
    end
  end
end
