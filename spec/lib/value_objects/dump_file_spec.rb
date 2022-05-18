# frozen_string_literal: true

require 'pg_export/value_objects/dump_file'

describe PgExport::ValueObjects::DumpFile do
  subject { described_class.new }

  describe '#read #write' do
    before(:each) do
      subject.write { |f| f << 'abc' }
      subject.rewind
    end

    it { expect(subject.read).to eq('abc') }
  end

  describe '#size' do
    before(:each) do
      subject.write { |f| f << 'a' * 1024 }
      subject.rewind
    end

    it { expect(subject.size).to eq(1024) }
    it { expect(subject.size_human).to eq('1.0kB') }
  end
end
