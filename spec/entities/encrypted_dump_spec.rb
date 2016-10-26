require 'spec_helper'

describe PgExport::EncryptedDump do
  subject { PgExport::EncryptedDump.new }

  it { expect(subject).to be_a(PgExport::Dump::Base) }
end
