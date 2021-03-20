# frozen_string_literal: true

class SshMock
  def passive=(*) end

  def exec!(*)
    []
  end

  def upload(*)
    self
  end

  def scp
    self
  end

  def wait; end

  def close; end

  def host; end
end
