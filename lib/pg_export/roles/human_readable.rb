class PgExport
  module Roles
    module HumanReadable
      def size_human
        {
          'B'  => 1024,
          'kB' => 1024 * 1024,
          'MB' => 1024 * 1024 * 1024,
          'GB' => 1024 * 1024 * 1024 * 1024,
          'TB' => 1024 * 1024 * 1024 * 1024 * 1024
        }.each_pair { |e, s| return "#{(size.to_f / (s / 1024)).round(2)}#{e}" if size < s }
      end
    end
  end
end
