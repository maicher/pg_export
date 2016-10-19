class PgExport
  class Dump
    TIMESTAMP_REGEX = '[0-9]{8}_[0-9]{6}'.freeze

    attr_reader :database, :dir, :dirname, :basename, :basename_gz, :regexp, :ftp_regexp, :pathname, :pathname_gz

    def initialize(a_database, a_dir)
      @database = a_database
      @dir = a_dir
      @dirname = absolute_path(dir)
      @basename = append_to_database(Time.now.strftime('%Y%m%d_%H%M%S'))
      @basename_gz = basename + '.gz'
      @regexp = Regexp.new(append_to_database(TIMESTAMP_REGEX))
      @ftp_regexp = append_to_database('*')
      @pathname = [dirname, basename].join('/')
      @pathname_gz = pathname + '.gz'
      create_dir_if_necessary
    end

    def size
      file_size(pathname)
    end

    def size_gz
      file_size(pathname_gz)
    end

    private

    def file_size(path)
      return unless File.exist?(path)
      bytes2human(File.size(path))
    end

    def bytes2human(bytes)
      {
        'B'  => 1024,
        'kB' => 1024 * 1024,
        'MB' => 1024 * 1024 * 1024,
        'GB' => 1024 * 1024 * 1024 * 1024,
        'TB' => 1024 * 1024 * 1024 * 1024 * 1024
      }.each_pair { |e, s| return "#{(bytes.to_f / (s / 1024)).round(2)}#{e}" if bytes < s }
    end

    def create_dir_if_necessary
      FileUtils.mkdir_p(dirname)
    end

    def append_to_database(segment)
      [database, segment].join('_')
    end

    def absolute_path(dir)
      if Pathname.new(dir).absolute?
        dir
      else
        [Pathname.pwd, dir].join('/')
      end
    end
  end
end
