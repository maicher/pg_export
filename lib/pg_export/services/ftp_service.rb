class PgExport
  class FtpService
    CHUNK_SIZE = (2**16).freeze

    def initialize(params)
      @host = params.fetch(:host)
      connection = Connection.new(params)
      @ftp = connection.ftp
      ObjectSpace.define_finalizer(self, proc { connection.close })
    end

    def list(regex_string)
      ftp.list(regex_string).map { |item| item.split(' ').last }.sort.reverse
    end

    def delete(filename)
      ftp.delete(filename)
    end

    def upload_file(path, name)
      ftp.putbinaryfile(path.to_s, name, CHUNK_SIZE)
    end

    def to_s
      host
    end

    private

    attr_reader :ftp, :host
  end
end
