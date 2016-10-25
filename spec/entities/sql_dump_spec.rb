require 'spec_helper'

describe PgExport::SqlDump do
  subject { PgExport::SqlDump.new }

  it { expect(subject).to be_a(PgExport::Dump::Base) }

  describe '#read_chunk' do
    before(:each) do
      stub_const('PgExport::Dump::Base::CHUNK_SIZE', 1)
      subject.write('abc')
      subject.rewind
    end
    it { expect(subject.read_chunk).to eq('a') }
  end
end
