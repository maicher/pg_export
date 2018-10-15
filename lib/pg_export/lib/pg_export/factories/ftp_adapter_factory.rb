# frozen_string_literal: true

# auto_register: false

require 'pg_export/lib/pg_export/adapters/ftp_adapter'
require 'pg_export/import'

class PgExport
  module Factories
    class FtpAdapterFactory
      include Import['config']

      def ftp_adapter
        ::PgExport::Adapters::FtpAdapter.new(
          host: config.ftp_host,
          user: config.ftp_user,
          password: config.ftp_password
        )
      end
    end
  end
end
