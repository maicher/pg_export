require 'pg_export/dump'

describe PgExport::Dump do
  subject { PgExport::Dump.new(name: 'Name', db_name: 'database_name') }

  it { expect(subject).to respond_to(:path) }
  it { expect(subject).to respond_to(:read) }
  it { expect(subject).to respond_to(:write) }
  it { expect(subject).to respond_to(:rewind) }
  it { expect(subject).to respond_to(:size) }
  it { expect(subject).to respond_to(:eof?) }
  it { expect(subject).to respond_to(:ext) }

  describe '#read #write' do
    before(:each) do
      subject.write('abc')
      subject.rewind
    end
    it { expect(subject.read).to eq('abc') }
  end

  describe '#size' do
    before(:each) do
      subject.write('abc')
      subject.rewind
    end
    it { expect(subject.size).to eq(3) }
  end
end
