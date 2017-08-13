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
    container[:ftp_repository].persist(dump)
    container[:ftp_repository].remove_old(config[:database], config[:keep_dumps])

    self
  end

  private

  def container
    @container ||= BootContainer.call(config.to_h)
  end

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
        container[:factory].build_dump(config[:database])
      )
    end
  end

  def open_ftp_connection
    Thread.new { container[:ftp_connection].open }
  end
end
