# frozen_string_literal: true

require 'pg_export/transactions/evaluator'
require 'pg_export/adapters/shell_adapter'
require 'pg_export/value_objects/result'

class PgExport
  module Transactions
    class ImportDumpInteractively
      def initialize(
        input:,
        shell_adapter:,
        gateway_dump_repository:,
        gateway_dump_file_factory:,
        open_connection:,
        decrypt_dump:,
        listeners:
      )
        @input = input
        @shell_adapter = shell_adapter
        @gateway_dump_repository = gateway_dump_repository
        @gateway_dump_file_factory = gateway_dump_file_factory

        @evaluator = Evaluator.new(listeners)
        @evaluator << open_connection
        @evaluator << method(:fetch_dumps)
        @evaluator << method(:select_dump)
        @evaluator << method(:download_dump)
        @evaluator << method(:close_connection)
        @evaluator << decrypt_dump
        @evaluator << method(:select_database)
        @evaluator << method(:restore)
      end

      def call(input)
        evaluator.call(input)
      end

      private

      attr_reader :evaluator, :input, :shell_adapter, :gateway_dump_repository, :gateway_dump_file_factory

      def fetch_dumps(database_name:, gateway:)
        dumps = gateway_dump_repository.all(database_name: database_name, gateway: gateway)
        return ValueObjects::Failure.new(message: 'No dumps') if dumps.none?

        ValueObjects::Success.new(gateway: gateway, dumps: dumps)
      end

      def select_dump(dumps:, gateway:)
        dump = input.select_dump(dumps)
        ValueObjects::Success.new(dump: dump, gateway: gateway)
      end

      def download_dump(dump:, gateway:)
        dump.file = gateway_dump_file_factory.by_name(name: dump.name, gateway: gateway)
        ValueObjects::Success.new(dump: dump, gateway: gateway)
      end

      def close_connection(dump:, gateway:)
        Thread.new { gateway.close }
        ValueObjects::Success.new(dump: dump)
      end

      def select_database(dump:)
        name = input.enter_database_name(dump.database)
        ValueObjects::Success.new(dump: dump, database: name)
      end

      def restore(dump:, database:)
        shell_adapter.pg_restore(dump.file, database)
        ValueObjects::Success.new(nil)
      rescue Adapters::ShellAdapter::PgRestoreError => e
        ValueObjects::Failure.new(message: e.to_s)
      end
    end
  end
end
