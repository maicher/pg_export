# frozen_string_literal: true

require 'pg_export/lib/pg_export/types'
require 'dry-struct'

class PgExport
  class Configuration < Dry::Struct
    attribute :dump_encryption_key, PgExport::Types::Strict::String.constrained(size: 16)
    attribute :gateway_host,        PgExport::Types::Strict::String
    attribute :gateway_user,        PgExport::Types::Strict::String
    attribute :gateway_password,    PgExport::Types::Strict::String.optional
    attribute :logger_format,       PgExport::Types::Coercible::String.enum('plain', 'timestamped', 'muted')
    attribute :keep_dumps,          PgExport::Types::Coercible::Integer.constrained(gteq: 0)

    def self.build(env)
      new(
        dump_encryption_key: env['PG_EXPORT_ENCRYPTION_KEY'],
        gateway_host: env['PG_EXPORT_GATEWAY_HOST'],
        gateway_user: env['PG_EXPORT_GATEWAY_USER'],
        gateway_password: env['PG_EXPORT_GATEWAY_PASSWORD'] == '' ? nil : env['PG_EXPORT_GATEWAY_PASSWORD'],
        logger_format: env['LOGGER_FORMAT'] || 'plain',
        keep_dumps: env['KEEP_DUMPS'] || 10
      )
    rescue Dry::Struct::Error => e
      raise PgExport::InitializationError, e.message.gsub('[PgExport::Configuration.new] ', '')
    end

    def gateway
      ENV['GATEWAY'].to_sym
    end

    def mode
      ENV['PG_EXPORT_MODE'].to_sym
    end

    def logger_muted?
      logger_format == 'muted'
    end
  end
end
