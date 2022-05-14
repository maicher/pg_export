# frozen_string_literal: true

require 'pg_export/container'
require 'pg_export/lib/pg_export/value_objects/dump_file'
require 'pg_export/lib/pg_export/value_objects/result'

class PgExport
  module Transactions
    class ExportDump
      OPERATIONS = %i[
        prepare_params
        build_dump
        encrypt_dump
        open_connection
        upload_dump
        remove_old_dumps
        close_connection
      ].freeze

      attr_reader :dump_factory, :bash_adapter, *OPERATIONS, :listeners

      def initialize(dump_factory:, bash_adapter:, encrypt_dump:, open_connection:, remove_old_dumps:, listeners:)
        @dump_factory = dump_factory
        @bash_adapter = bash_adapter
        @prepare_params = method(:prepare_params_operation)
        @build_dump = method(:build_dump_operation)
        @encrypt_dump = encrypt_dump
        @open_connection = open_connection
        @upload_dump = method(:upload_dump_operation)
        @remove_old_dumps = remove_old_dumps
        @close_connection = method(:close_connection_operation)
        @listeners = listeners
      end

      def call(**input)
        result = ValueObjects::Success.new(input)

        OPERATIONS.each do |operation_name|
          listener = listeners[operation_name]

          result = result.bind do
            r = operation(operation_name).call(**result.value)

            r.on_step_succeeded do
              listener.on_step_succeeded({value: r.value})
            end if listener

            r
          end
        end

        result
      end

      private

      def operation(operation_name)
        public_send(operation_name)
      rescue NoMethodError => e
        raise ArgumentError, "Operation #{operation_name} does not exist"
      end

      def prepare_params_operation(database_name:)
        database_name = database_name.to_s

        return ValueObjects::Failure.new(message: 'Invalid database name') if database_name.empty?

        ValueObjects::Success.new(database_name: database_name)
      end

      def build_dump_operation(database_name:)
        dump = dump_factory.plain(
          database: database_name,
          file: bash_adapter.pg_dump(ValueObjects::DumpFile.new, database_name)
        )
        ValueObjects::Success.new(dump: dump)
      rescue bash_adapter.class::PgDumpError => e
        ValueObjects::Failure.new(message: 'Unable to dump database: ' + e.to_s)
      end

      def upload_dump_operation(dump:, gateway:)
        gateway.persist(dump.file, dump.name)
        ValueObjects::Success.new(dump: dump, gateway: gateway)
      end

      def close_connection_operation(removed_dumps:, gateway:)
        gateway.close
        ValueObjects::Success.new(gateway: gateway)
      end
    end
  end
end
