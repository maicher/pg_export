$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pg_export'
require 'pg'
require 'simplecov'
SimpleCov.start

NullLogger = Logger.new(nil)

class FtpMock
  def passive=(*) end

  def close; end
end
