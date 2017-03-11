require 'spec_helper'

describe PgExport do
  let(:database) { 'some_database' }
  let(:keep) { 10 }

  subject do
    PgExport.new do |config|
      config.database = database
      config.keep_dumps = keep
      config.dump_encryption_key = '1234567890abcdef'
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
    let(:sql_dump) { Object.new }
    let(:enc_dump) { Object.new }

    before(:each) do
      allow(Net::FTP).to receive(:new).and_return(mock)
      allow_any_instance_of(PgExport::Configuration).to receive(:validate)
      allow_any_instance_of(PgExport::BashUtils).to receive(:create_dump).and_return(sql_dump)
      allow_any_instance_of(PgExport::Aes::Encryptor).to receive(:call).with(sql_dump).and_return(enc_dump)
      allow_any_instance_of(PgExport::DumpStorage).to receive(:upload).with(enc_dump)
      allow_any_instance_of(PgExport::DumpStorage).to receive(:remove_old)
    end
    it { subject.call }
  end
end
