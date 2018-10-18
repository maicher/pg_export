# frozen_string_literal: true

class PgExport
  module Ui
    module Plain
      class Input
        def select_dump(dumps)
          dumps[0]
        end

        def enter_database_name(default)
          default
        end
      end
    end
  end
end
