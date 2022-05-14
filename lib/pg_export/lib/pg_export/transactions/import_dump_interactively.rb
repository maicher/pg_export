# frozen_string_literal: true

require 'pg_export/container'
require 'pg_export/lib/pg_export/value_objects/result'

class PgExport
  module Transactions
    class ImportDumpInteractively
      OPERATIONS = %i[
        open_connection
        fetch_dumps
        select_dump
        download_dump
        close_connection
        decrypt_dump
        select_database
        restore
      ].freeze

      attr_reader :input, :bash_adapter, :gateway_dump_repository, :gateway_dump_file_repository, *OPERATIONS, :listeners

      def initialize(input:, bash_adapter:, gateway_dump_repository:, gateway_dump_file_repository:, open_connection:, decrypt_dump:, listeners:)
        @input = input
        @bash_adapter = bash_adapter
        @gateway_dump_repository = gateway_dump_repository
        @gateway_dump_file_repository = gateway_dump_file_repository
        @open_connection = open_connection
        @fetch_dumps = method(:fetch_dumps_operation)
        @select_dump = method(:select_dump_operation)
        @download_dump = method(:download_dump_operation)
        @close_connection = method(:close_connection_operation)
        @decrypt_dump = decrypt_dump
        @select_database = method(:select_database_operation)
        @restore = method(:restore_operation)
        @listeners = listeners
      end

      def call(**input)
        result = ValueObjects::Success.new(input)

        OPERATIONS.each do |operation_name|
          listener = listeners[operation_name]

          result = result.bind do
            listener.on_step({value: result.value}) if listener && listener.respond_to?(:on_step)

            r = operation(operation_name).call(**result.value)

            r.on_step_succeeded do
              listener.on_step_succeeded({value: r.value})
            end if listener && listener.respond_to?(:on_step_succeeded)

            r
          end
        end

        result
      end

      private

      def operation(operation_name)
        public_send(operation_name) || (raise ArgumentError, "Operation #{operation_name} does not exist")
      rescue NoMethodError => e
        raise ArgumentError, "Operation #{operation_name} does not exist"
      end

      def fetch_dumps_operation(database_name:, gateway:)
        dumps = gateway_dump_repository.all(database_name: database_name, gateway: gateway)
        return ValueObjects::Failure.new(message: 'No dumps') if dumps.none?

        ValueObjects::Success.new(gateway: gateway, dumps: dumps)
      end

      def select_dump_operation(dumps:, gateway:)
        dump = input.select_dump(dumps)
        ValueObjects::Success.new(dump: dump, gateway: gateway)
      end

      def download_dump_operation(dump:, gateway:)
        dump.file = gateway_dump_file_repository.by_name(name: dump.name, gateway: gateway)
        ValueObjects::Success.new(dump: dump, gateway: gateway)
      end

      def close_connection_operation(dump:, gateway:)
        Thread.new { gateway.close }
        ValueObjects::Success.new(dump: dump)
      end

      def select_database_operation(dump:)
        name = input.enter_database_name(dump.database)
        ValueObjects::Success.new(dump: dump, database: name)
      end

      def restore_operation(dump:, database:)
        bash_adapter.pg_restore(dump.file, database)
        ValueObjects::Success.new({})
      rescue bash_adapter.class::PgRestoreError => e
        ValueObjects::Failure.new(message: e.to_s)
      end
    end
  end
end
