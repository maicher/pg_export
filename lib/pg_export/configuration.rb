class PgExport
  class Configuration
    FIELD_REQUIRED = 'Field %s is required'.freeze
    INVALID_ENCRYPTION_KEY_LENGTH = 'Dump encryption key should have exact 16 characters. Edit your DUMP_ENCRYPTION_KEY env variable.'.freeze

    DEFAULTS = {
      database: nil,
      keep_dumps: ENV['KEEP_DUMPS'] || 10,
      dump_encryption_key: ENV['DUMP_ENCRYPTION_KEY'],
      ftp_host: ENV['BACKUP_FTP_HOST'],
      ftp_user: ENV['BACKUP_FTP_USER'],
      ftp_password: ENV['BACKUP_FTP_PASSWORD']
    }.freeze

    attr_accessor *DEFAULTS.keys

    def initialize
      DEFAULTS.each_pair do |key, value|
        send("#{key}=", value)
      end
    end

    def validate
      DEFAULTS.keys.each do |field|
        raise InvalidConfigurationError, FIELD_REQUIRED % field if public_send(field).nil?
      end
      raise InvalidConfigurationError, INVALID_ENCRYPTION_KEY_LENGTH unless dump_encryption_key.length == 16
    end

    def ftp_params
      {
        host: ftp_host,
        user: ftp_user,
        password: ftp_password
      }
    end

    def to_s
      DEFAULTS.keys.map(&method(:print_attr))
    end

    private

    def print_attr(key)
      if %i(ftp_password dump_encryption_key).include?(key)
        if public_send(key)
          "#{key}: #{public_send(key)[0..2]}***\n"
        else
          "#{key}:\n"
        end
      else
        "#{key}: #{public_send(key)}\n"
      end
    end
  end
end
