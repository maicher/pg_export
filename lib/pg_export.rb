require 'logger'
require 'tempfile'
require 'zlib'
require 'net/ftp'
require 'openssl'
require 'forwardable'
require 'open3'

require 'cli_spinnable'

require 'pg_export/version'
require 'pg_export/logging'
require 'pg_export/errors'
require 'pg_export/services_container'
require 'pg_export/configuration'
require 'pg_export/entities/dump/size_human'
require 'pg_export/entities/dump/base'
require 'pg_export/entities/plain_dump'
require 'pg_export/entities/encrypted_dump'
require 'pg_export/services/ftp_service'
require 'pg_export/services/ftp_service/connection'
require 'pg_export/services/utils'
require 'pg_export/services/dump_storage'
require 'pg_export/services/aes'
require 'pg_export/services/encrypt'
require 'pg_export/services/decrypt'

class PgExport
  extend Forwardable

  def_delegators :services_container, :config, :utils, :ftp_service, :dump_storage, :connection_initializer, :connection_closer, :encrypt, :decrypt

  def initialize
    @services_container = ServicesContainer
    yield config if block_given?
    config.validate
  end

  def call
    dump = nil
    [].tap do |arr|
      arr << Thread.new { dump = create_dump }
      arr << Thread.new { initialize_connection }
    end.each(&:join)

    dump_storage.upload(dump)
    dump_storage.remove_old
    self
  end

  private

  attr_reader :services_container

  def create_dump
    encrypt.call(utils.create_dump)
  end

  def initialize_connection
    connection_initializer.call
    self
  end
end
