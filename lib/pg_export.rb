require 'pg_export/version'
require 'pg_export/configuration'
require 'pg_export/boot_container'
require 'pg_export/errors'
require 'pry'

class PgExport
  def initialize(**args)
    @config = Configuration.new(**args)
  rescue Dry::Struct::Error => e
    raise InvalidConfigurationError, e
  end

  def call
    dump = build_dump
    encrypted_dump = encrypt(dump)
    persist(encrypted_dump)
    remove_old
  end

  private

  attr_reader :config

  def build_dump
    container[:bash_factory].build_dump(config[:database])
  end

  def encrypt(dump)
    container[:encryptor].call(dump)
  end

  def persist(encrypted_dump)
    container[:ftp_repository].persist(encrypted_dump)
  end

  def remove_old
    container[:ftp_repository].remove_old(config[:database], config[:keep_dumps])
  end

  def container
    @container ||= BootContainer.call(config.to_h)
  end
end
