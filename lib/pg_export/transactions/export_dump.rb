# frozen_string_literal: true

require 'pg_export/version'
require 'pg_export/boot_container'
require 'pg_export/errors'
require 'dry/transaction'
require 'dry/validation'

class PgExport
  module Transactions
    class ExportDump
      include Dry::Transaction

      Schema = Dry::Validation.Schema do
        required(:database_name).filled(:str?, min_size?: 1)
        required(:keep_dumps).filled(:int?, gteq?: 0)
      end

      attr_accessor :container

      step :validate_params
      step :export

      private

      def validate_params(database_name:, keep_dumps:)
        validation = Schema.call(database_name: database_name, keep_dumps: keep_dumps)
        if validation.success?
          Success(validation.to_h)
        else
          raise ArgumentError, validation.messages(full: true)
        end
      end

      def export(database_name:, keep_dumps:)
        container[:create_and_export_dump].call(database_name, keep_dumps)

        Success({})
      end
    end
  end
end
