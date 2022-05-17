# frozen_string_literal: true

require 'pg_export/version'
require 'pg_export/configuration'
require 'pg_export/factory'

class PgExport
  class InitializationError < StandardError; end

  attr_reader :config

  def initialize
    @config = PgExport::Configuration.build(ENV)
    @factory = PgExport::Factory.new(config: config)
  end

  def call(database_name, &block)
    factory.transaction.call(database_name: database_name, &block)
  end

  def gateway_welcome
    container.gateway_factory.gateway.welcome
  end

  private

  attr_reader :factory
end
