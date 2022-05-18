# frozen_string_literal: true

require 'pg_export/transactions/evaluator'
require 'pg_export/value_objects/dump_file'
require 'pg_export/adapters/shell_adapter'
require 'pg_export/value_objects/result'

class PgExport
  module Transactions
    class ExportDump
      def initialize(dump_factory:, shell_adapter:, encrypt_dump:, open_connection:, remove_old_dumps:, listeners:)
        @dump_factory = dump_factory
        @shell_adapter = shell_adapter

        @evaluator = Evaluator.new(listeners)
        @evaluator << method(:prepare_params)
        @evaluator << method(:build_dump)
        @evaluator << encrypt_dump
        @evaluator << open_connection
        @evaluator << method(:upload_dump)
        @evaluator << remove_old_dumps
        @evaluator << method(:close_connection)
      end

      def call(input)
        evaluator.call(input)
      end

      private

      attr_reader :evaluator, :dump_factory, :shell_adapter

      def prepare_params(database_name:)
        database_name = database_name.to_s

        return ValueObjects::Failure.new(message: 'Invalid database name') if database_name.empty?

        ValueObjects::Success.new(database_name: database_name)
      end

      def build_dump(database_name:)
        dump = dump_factory.plain(
          database: database_name,
          file: shell_adapter.pg_dump(ValueObjects::DumpFile.new, database_name)
        )
        ValueObjects::Success.new(dump: dump)
      rescue Adapters::ShellAdapter::PgDumpError => e
        ValueObjects::Failure.new(message: 'Unable to dump database: ' + e.to_s)
      end

      def upload_dump(dump:, gateway:)
        gateway.persist(dump.file, dump.name)
        ValueObjects::Success.new(dump: dump, gateway: gateway)
      end

      def close_connection(removed_dumps:, gateway:)
        gateway.close
        ValueObjects::Success.new
      end
    end
  end
end
