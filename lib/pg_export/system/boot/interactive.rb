# frozen_string_literal: true

PgExport::Container.boot(:interactive) do
  start do
    use :main
  end
end
