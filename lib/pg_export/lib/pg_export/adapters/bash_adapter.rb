# frozen_string_literal: true

require 'open3'

class PgExport
  module Adapters
    class BashAdapter
      class PgRestoreError < StandardError; end
      class PgDumpError < StandardError; end

      def pg_dump(file, db_name)
        popen("pg_dump -Fc --file #{file.path} #{db_name}") do |errors|
          raise PgDumpError, errors unless errors.empty?
        end

        file
      end

      def pg_restore(file, db_name)
        popen("pg_restore -c -d #{db_name} #{file.path}") do |errors|
          raise PgRestoreError, errors if /FATAL/ =~ errors
        end
      end

      private

      def popen(command)
        Open3.popen3(command) do |_, _, err|
          errors = err.read
          yield errors
        end

        self
      end
    end
  end
end
