require 'pg_export/version'
require 'pg_export/configuration'
require 'pg_export/boot_container'
require 'pry'

class PgExport
  attr_reader :config

  def initialize(**args)
    @config = Configuration.new(**args)
  end

  def call
    concurrently do |threads|
      threads << create_dump
      threads << open_ftp_connection
    end
    container[:repository].upload(dump)
    container[:repository].remove_old
    self
  end

  def container
    @container ||= BootContainer.call(config.to_h)
  end

  private

  def concurrently
    [].tap do |threads|
      yield threads
    end.each(&:join)
  end

  def dump
    create_dump[:dump]
  end

  def create_dump
    @create_dump ||= Thread.new do
      Thread.current[:dump] = container[:encryptor].call(
        container[:bash_utils].create_dump
      )
    end
  end

  def open_ftp_connection
    Thread.new { container[:ftp_connection].open }
  end
end
