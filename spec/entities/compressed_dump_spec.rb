require 'spec_helper'

describe PgExport::CompressedDump do
  subject { PgExport::CompressedDump.new }

  it { expect(subject).to be_a(PgExport::Dump::Base) }
end
