require 'logger'
require 'pathname'
require 'fileutils'
require 'zlib'
require 'net/ftp'

require 'pg'

require 'pg_export/version'
require 'pg_export/logging'
require 'pg_export/configuration'
require 'pg_export/errors'
require 'pg_export/dump'
require 'pg_export/actions'
require 'pg_export/ftp_service'
require 'pg_export/ftp_service/connection'

class PgExport
  include Logging

  def initialize
    @config = Configuration.new
    yield config if block_given?
    config.validate
    @dump = Dump.new(config.database, config.dumpfile_dir)
  end

  def initialize_ftp_service
    self.ftp_service = FtpService.new(config.ftp_params)
  end

  def call
    t = []
    t << Thread.new { perform_local_job }
    t << Thread.new { initialize_ftp_service }
    t.each(&:join)
    perform_ftp_job
    self
  end

  private

  attr_reader :config, :dump
  attr_accessor :ftp_service

  def perform_local_job
    CreateDump.new(dump).call
    CompressDump.new(dump).call
    RemoveOldDumps.new(dump, config.keep_dumps).call
  end

  def perform_ftp_job
    SendDumpToFtp.new(dump, ftp_service).call
    RemoveOldDumpsFromFtp.new(dump, ftp_service, config.keep_ftp_dumps).call
  end
end
