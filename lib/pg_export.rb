require 'logger'
require 'tempfile'
require 'zlib'
require 'net/ftp'
require 'openssl'
require 'forwardable'

require 'pg_export/version'
require 'pg_export/logging'
require 'pg_export/errors'
require 'pg_export/configuration'
require 'pg_export/concurrency'
require 'pg_export/entities/dump/size_human'
require 'pg_export/entities/dump/base'
require 'pg_export/entities/plain_dump'
require 'pg_export/entities/encrypted_dump'
require 'pg_export/services/ftp_service'
require 'pg_export/services/ftp_service/connection'
require 'pg_export/services/utils'
require 'pg_export/services/dump_storage'
require 'pg_export/services/aes'
require 'pg_export/refinements/colourable_string'

class PgExport
  include Concurrency

  def initialize
    @config = Configuration.new
    yield config if block_given?
    config.validate
  end

  def call
    concurrently do |job|
      job << create_dump
      job << initialize_dump_storage
    end
    dump_storage.upload(dump)
    dump_storage.remove_old(keep: config.keep_dumps)
    self
  end

  def initialize_dump_storage
    ftp_service = FtpService.new(config.ftp_params)
    self.dump_storage = DumpStorage.new(ftp_service, config.database)
  end

  def utils
    @utils ||= Utils.new(
        Aes.encryptor(config.dump_encryption_key),
        Aes.decryptor(config.dump_encryption_key)
    )
  end

  private

  attr_reader :config
  attr_accessor :dump, :dump_storage

  def create_dump
    sql_dump = utils.create_dump(config.database)
    enc_dump = utils.encrypt(sql_dump)
    self.dump = enc_dump
  end
end
