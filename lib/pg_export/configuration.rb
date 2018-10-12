# frozen_string_literal: true

require 'dry-struct'

class PgExport
  class InitializationError < StandardError; end

  class Configuration < Dry::Struct
    include Dry::Types.module

    attribute :dump_encryption_key, Strict::String.constrained(size: 16)
    attribute :ftp_host,            Strict::String
    attribute :ftp_user,            Strict::String
    attribute :ftp_password,        Strict::String
    attribute :logger_format,       Coercible::String.enum('plain', 'timestamped', 'muted')

    def self.build_from_env
      new(
        dump_encryption_key: ENV['DUMP_ENCRYPTION_KEY'],
        ftp_host: ENV['BACKUP_FTP_HOST'],
        ftp_user: ENV['BACKUP_FTP_USER'],
        ftp_password: ENV['BACKUP_FTP_PASSWORD'],
        logger_format: ENV['LOGGER_FORMAT'] || 'plain'
      )
    rescue Dry::Struct::Error => e
      raise PgExport::InitializationError, e
    end
  end
end
