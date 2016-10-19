class PgExport
  class Configuration
    DEFAULTS = {
      database: nil,
      dumpfile_dir: ENV['DUMPFILE_DIR'] || 'tmp/dumps',
      keep_dumps: ENV['KEEP_DUMPS'].to_i || 10,
      keep_ftp_dumps: ENV['KEEP_FTP_DUMPS'].to_i || 10,
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
  end
end
