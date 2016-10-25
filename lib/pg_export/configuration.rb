class PgExport
  class Configuration
    DEFAULTS = {
      database: nil,
      keep_dumps: ENV['KEEP_DUMPS'] || 10,
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
        raise InvalidConfigurationError, "Field #{field} is required" if send(field).nil?
      end
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
      if key == :ftp_password
        if send(key)
          "#{key}: #{send(key)[0..2]}***\n"
        else
          "#{key}:\n"
        end
      else
        "#{key}: #{send(key)}\n"
      end
    end
  end
end
