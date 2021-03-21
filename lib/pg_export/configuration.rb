# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

class PgExport
  class Configuration < Dry::Struct
    include Dry::Types()

    attribute :dump_encryption_key, Strict::String.constrained(size: 16)
    attribute :gateway_host,        Strict::String
    attribute :gateway_user,        Strict::String
    attribute :gateway_password,    Strict::String.optional
    attribute :logger_format,       Coercible::String.enum('plain', 'timestamped', 'muted')
    attribute :keep_dumps,          Coercible::Integer.constrained(gteq: 0)

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
