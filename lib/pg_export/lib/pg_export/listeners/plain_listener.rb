# frozen_string_literal: true

# auto_register: false

require 'pg_export/import'

class PgExport
  module Listeners
    class PlainListener
      include Import['logger']
    end
  end
end
