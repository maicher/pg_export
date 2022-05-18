# frozen_string_literal: true

require 'pg_export/version'
require 'pg_export/configuration'
require 'pg_export/configuration_parser'
require 'pg_export/commands_factory'

class PgExport
  def initialize(config)
    raise ArgumentError, 'config is not a PgExport::Configuration' unless config.is_a?(PgExport::Configuration)

    @command_name = config.command
    @database_name = config.database
    @commands_factory = PgExport::CommandsFactory.new(config: config)
  end

  def call
    commands_factory
      .public_send(command_name)
      .call(database_name: database_name)
  end

  private

  attr_reader :command_name, :database_name, :commands_factory
end
