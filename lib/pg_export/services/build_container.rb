class PgExport
  module Services
    class BuildContainer
      class << self
        def call(config)
          container = {}
          aes = Aes.new(config[:dump_encryption_key])
          container[:encryptor] = aes.build_encryptor
          container[:decryptor] = aes.build_decryptor
          container[:bash_utils] = BashUtils.new(config[:database])
          container[:ftp_connection] = FtpConnection.new(
            host: config[:ftp_host],
            user: config[:ftp_user],
            password: config[:ftp_password]
          )
          container[:ftp_adapter] = FtpAdapter.new(container[:ftp_connection])
          container[:dump_storage] = DumpStorage.new(
            container[:ftp_adapter],
            config[:database],
            config[:keep_dumps]
          )
          container[:database] = config[:database]
          container
        end
      end
    end
  end
end
