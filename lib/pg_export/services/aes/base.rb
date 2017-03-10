class PgExport
  class Aes
    class Base
      include Logging

      def initialize(cipher)
        @cipher = cipher
      end

      private

      def copy_using(cipher, from:, to:)
        cipher.reset
        to.open(:write) do |f|
          from.each_chunk do |chunk|
            f << cipher.update(chunk)
          end
          f << cipher.final
        end
        self
      end

      attr_reader :cipher
    end
  end
end
