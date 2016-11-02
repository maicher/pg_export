class PgExport
  module Interactive
    module ColourableString
      refine String do
        def red
          "\e[31m#{self}\e[0m"
        end

        def green
          "\e[38;5;34m#{self}\e[0m"
        end

        def gray
          "\e[37m#{self}\e[0m"
        end
      end
    end
  end
end
