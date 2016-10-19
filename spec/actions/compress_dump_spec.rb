require 'spec_helper'

describe PgExport::CompressDump do
  describe '#call' do
    let!(:dump) { PgExport::Dump.new('database', 'spec/tmp/dumps') }
    let!(:dump_pathname) { dump.pathname }

    context 'when specified file does not exist' do
      subject { PgExport::CompressDump.new(dump) }
      it { expect { subject.call }.to raise_error(PgExport::DumpFileDoesNotExistError) }
    end

    context 'when specified file exist' do
      before(:each) { File.open(dump_pathname, 'w') { |f| f.write('test') } }
      after(:each) { File.delete("#{dump_pathname}.gz") }

      subject { PgExport::CompressDump.new(dump) }

      it { expect { subject.call }.not_to raise_error }

      it 'should gzip dumpfile' do
        expect { subject.call }.to change { File.exist?("#{dump_pathname}.gz") }.from(false).to(true)
      end

      it 'should remove dumpfile' do
        expect { subject.call }.to change { File.exist?(dump_pathname.to_s) }.from(true).to(false)
      end
    end
  end
end
