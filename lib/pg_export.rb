require 'pg_export/version'
require 'pg_export/configuration'
require 'pg_export/boot_container'
require 'pg_export/roles/interactive'
require 'pg_export/errors'
require 'pg_export/roles/validatable'

class PgExport
  include Roles::Validatable

  def initialize(**args)
    config = Configuration.new(**args)
    extend Roles::Interactive if config.interactive
    @container = BootContainer.call(config.to_h)
  rescue Dry::Struct::Error => e
    raise ArgumentError, e
  end

  def call(database_name, keep_dumps)
    container[:create_and_export_dump].call(
      validate_database_name(database_name),
      validate_keep_dumps(keep_dumps)
    )
  end

  private

  attr_reader :container
end
