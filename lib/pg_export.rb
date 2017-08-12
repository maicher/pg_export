require 'logger'
require 'tempfile'
require 'zlib'
require 'net/ftp'
require 'forwardable'
require 'open3'

require 'pg_export/version'
require 'pg_export/includable_modules/dump/size_human'
require 'pg_export/errors'
require 'pg_export/configuration'
require 'pg_export/dump'
require 'pg_export/services/build_container'
require 'pg_export/services/ftp_adapter'
require 'pg_export/services/ftp_connection'
require 'pg_export/services/bash_utils'
require 'pg_export/services/dump_storage'
require 'pg_export/aes'
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
    container[:dump_storage].upload(dump)
    container[:dump_storage].remove_old
    self
  end

  def container
    @container ||= Services::BuildContainer.call(config.to_h)
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
