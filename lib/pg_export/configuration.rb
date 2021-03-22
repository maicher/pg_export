# frozen_string_literal: true

require 'pg_export/lib/pg_export/types'
require 'dry-struct'

class PgExport
  class Configuration < Dry::Struct
    attribute :encryption_key,       PgExport::Types::Strict::String.constrained(size: 16)
    attribute :encryption_algorithm, PgExport::Types::Strict::String
    attribute :gateway_host,         PgExport::Types::Strict::String
    attribute :gateway_user,         PgExport::Types::Strict::String
    attribute :gateway_password,     PgExport::Types::Strict::String.optional
    attribute :logger_format,        PgExport::Types::Coercible::Symbol.enum(:plain, :timestamped, :muted)
    attribute :keep_dumps,           PgExport::Types::Coercible::Integer.constrained(gteq: 0)
    attribute :gateway,              PgExport::Types::Coercible::Symbol.enum(:ftp, :ssh)
    attribute :mode,                 PgExport::Types::Coercible::Symbol.enum(:plain, :interactive)

    def self.build(env)
      new(
        encryption_key: env['PG_EXPORT_ENCRYPTION_KEY'],
        encryption_algorithm: env['PG_EXPORT_ENCRYPTION_ALGORITHM'],
        gateway_host: env['PG_EXPORT_GATEWAY_HOST'],
        gateway_user: env['PG_EXPORT_GATEWAY_USER'],
        gateway_password: env['PG_EXPORT_GATEWAY_PASSWORD'] == '' ? nil : env['PG_EXPORT_GATEWAY_PASSWORD'],
        logger_format: env['LOGGER_FORMAT'] || 'plain',
        keep_dumps: env['KEEP_DUMPS'] || 10,
        gateway: env['GATEWAY'],
        mode: env['PG_EXPORT_MODE']
      )
    rescue Dry::Struct::Error => e
      raise PgExport::InitializationError, e.message.gsub('[PgExport::Configuration.new] ', '')
    end
  end
end
