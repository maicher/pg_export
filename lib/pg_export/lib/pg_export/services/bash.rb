# frozen_string_literal: true

require 'open3'

class PgExport
  module Services
    class Bash
      class PgRestoreError < StandardError; end
      class PgDumpError < StandardError; end

      def pg_dump(path, db_name)
        popen("pg_dump -Fc --file #{path} #{db_name}") do |errors|
          raise PgDumpError, errors unless errors.empty?
        end
      end

      def pg_restore(path, db_name)
        popen("pg_restore -c -d #{db_name} #{path}") do |errors|
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
