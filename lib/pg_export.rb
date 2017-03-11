require 'logger'
require 'tempfile'
require 'zlib'
require 'net/ftp'
require 'openssl'
require 'forwardable'
require 'open3'

require 'pg_export/version'
require 'pg_export/includable_modules/logging'
require 'pg_export/includable_modules/dump/size_human'
require 'pg_export/includable_modules/services_container'
require 'pg_export/errors'
require 'pg_export/configuration'
require 'pg_export/entities/dump/base'
require 'pg_export/entities/plain_dump'
require 'pg_export/entities/encrypted_dump'
require 'pg_export/services/ftp_adapter'
require 'pg_export/services/ftp_connection'
require 'pg_export/services/bash_utils'
require 'pg_export/services/dump_storage'
require 'pg_export/services/aes'
require 'pg_export/services/aes/base'
require 'pg_export/services/aes/encryptor'
require 'pg_export/services/aes/decryptor'

class PgExport
  extend Forwardable
  include ServicesContainer

  def_delegators :services_container, :config, :bash_utils, :dump_storage, :ftp_connection, :encryptor, :decryptor

  def initialize
    yield config if block_given?
  end

  def call
    config.validate
    concurrently do |threads|
      threads << create_dump
      threads << open_ftp_connection
    end
    dump_storage.upload(dump)
    dump_storage.remove_old
    self
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
      Thread.current[:dump] = encryptor.call(bash_utils.create_dump)
    end
  end

  def open_ftp_connection
    Thread.new { ftp_connection.open }
  end
end
