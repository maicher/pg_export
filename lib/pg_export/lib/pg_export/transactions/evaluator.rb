# frozen_string_literal: true

class PgExport
  module Transactions
    class Evaluator
      def initialize(listeners)
        @operations = []
        @listeners = listeners
      end

      def <<(operation)
        operations << operation
      end

      def call(input)
        result = ValueObjects::Success.new(input)

        operations.each do |operation|
          result = result.bind do
            call_operation(operation, result)
          end
        end

        result
      end

      private

      attr_reader :operations, :listeners

      def call_operation(operation, input)
        listener = listeners[operation.name]

        before_call(listener, input)
        result = operation.call(**input.value)
        after_call(listener, result)
        result
      end

      def before_call(listener, input)
        return if listener.nil?

        listener.on_step(value: input.value)
      end

      def after_call(listener, result)
        return if listener.nil?

        result.on_success do
          listener.on_step_succeeded(value: result.value)
        end

        result.on_failure do
          listener.on_step_failed(value: result.value)
        end
      end
    end
  end
end
