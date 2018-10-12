# frozen_string_literal: true

require_relative 'container'

class PgExport
  Import = PgExport::Container.injector.hash
end
