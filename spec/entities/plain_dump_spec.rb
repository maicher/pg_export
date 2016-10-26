require 'spec_helper'

describe PgExport::PlainDump do
  subject { PgExport::PlainDump.new }

  it { expect(subject).to be_a(PgExport::Dump::Base) }
end
