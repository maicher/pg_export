# frozen_string_literal: true

class PgExport
  module Roles
    module HumanReadable
      MAPPING = {
        'B'  => 1024,
        'kB' => 1024 * 1024,
        'MB' => 1024 * 1024 * 1024,
        'GB' => 1024 * 1024 * 1024 * 1024,
        'TB' => 1024 * 1024 * 1024 * 1024 * 1024
      }.freeze

      def size_human
        MAPPING.each_pair { |e, s| return "#{(size.to_f / (s / 1024)).round(2)}#{e}" if size < s }
      end
    end
  end
end
