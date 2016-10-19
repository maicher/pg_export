class PgExport
  class FtpService
    def initialize(params)
      connection = Connection.new(params)
      @ftp = connection.ftp
      ObjectSpace.define_finalizer(self, proc { connection.close })
    end

    def list(regexp)
      ftp.list(regexp).map { |item| item.split(' ').last }.sort.reverse
    end

    def delete(filename)
      ftp.delete(filename)
    end

    def upload_file(path)
      ftp.putbinaryfile(path.to_s)
    end

    private

    attr_reader :ftp
  end
end
