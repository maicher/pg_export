require 'spec_helper'

describe PgExport do
  subject do
    PgExport.new do |config|
      config.database = 'some_database'
      config.dumpfile_dir = 'spec/tmp/dumps'
      config.ftp_host = 'ftp.example.com'
      config.ftp_user = 'user'
      config.ftp_password = 'pass'
    end
  end

  it 'has a version number' do
    expect(PgExport::VERSION).not_to be nil
  end

  describe '#call' do
    let(:mock) { FtpMock.new }
    before(:each) do
      allow(Net::FTP).to receive(:new).and_return(mock)
      allow_any_instance_of(PgExport::CreateDump).to receive(:call)
      allow_any_instance_of(PgExport::CompressDump).to receive(:call)
      allow_any_instance_of(PgExport::RemoveOldDumps).to receive(:call)
      allow_any_instance_of(PgExport::SendDumpToFtp).to receive(:call)
      allow_any_instance_of(PgExport::RemoveOldDumpsFromFtp).to receive(:call)
    end
    it { subject.call }
  end
end
