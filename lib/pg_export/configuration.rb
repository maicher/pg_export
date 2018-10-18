# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

class PgExport
  class Configuration < Dry::Struct
    include Dry::Types.module

    attribute :dump_encryption_key, Strict::String.constrained(size: 16)
    attribute :ftp_host,            Strict::String
    attribute :ftp_user,            Strict::String
    attribute :ftp_password,        Strict::String
    attribute :logger_format,       Coercible::String.enum('plain', 'timestamped', 'muted')
    attribute :keep_dumps,          Coercible::Integer.constrained(gteq: 0)

    def self.build(env)
      new(
        dump_encryption_key: env['DUMP_ENCRYPTION_KEY'],
        ftp_host: env['BACKUP_FTP_HOST'],
        ftp_user: env['BACKUP_FTP_USER'],
        ftp_password: env['BACKUP_FTP_PASSWORD'],
        logger_format: env['LOGGER_FORMAT'] || 'plain',
        keep_dumps: env['KEEP_DUMPS'] || 10
      )
    rescue Dry::Struct::Error => e
      raise PgExport::InitializationError, e.message.gsub('[PgExport::Configuration.new] ', '')
    end

    def logger_muted?
      logger_format == 'muted'
    end
  end
end
