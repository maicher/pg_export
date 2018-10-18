# frozen_string_literal: true

class FtpMock
  def passive=(*) end

  def list(*)
    []
  end

  def close; end

  def host; end
end
