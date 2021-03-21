# frozen_string_literal: true

require 'dry/system/container'

class PgExport
  class Container < Dry::System::Container
    configure do
      config.root = Pathname(__FILE__).realpath.dirname
      config.name = :pg_export
      config.default_namespace = 'pg_export'
      config.auto_register = %w[lib]
    end

    load_paths!('lib')

    boot(:main) do |system|
      use(:config)
      use(system[:config].gateway) # ftp/ssh
      use(:operations)
      use(system[:config].mode)    # plain/interactive
    end
  end
end
