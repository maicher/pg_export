require 'pg_export'
require 'ftp_mock'

describe PgExport do
  let(:database) { 'some_database' }
  let(:keep) { 10 }

  let(:pg_export) { PgExport.new(**params) }

  let(:params) do
    {
      database: database,
      keep_dumps: keep,
      dump_encryption_key: '1234567890abcdef',
      ftp_host: 'ftp.example.com',
      ftp_user: 'user',
      ftp_password: 'pass',
      logger_format: :muted
    }
  end

  it 'has a version number' do
    expect(PgExport::VERSION).not_to be nil
  end

  describe '.new' do
    subject { pg_export }

    context 'when valid params' do
      it { expect { subject }.not_to raise_error }
    end

    context 'when invalid params' do
      before { allow(PgExport::Configuration).to receive(:new).and_raise(Dry::Struct::Error) }
      it { expect { subject }.to raise_error(PgExport::InvalidConfigurationError) }
    end
  end

  describe '#call' do
    subject { pg_export.call }

    let(:mock) { FtpMock.new }
    let(:sql_dump) { Object.new }
    let(:enc_dump) { Object.new }

    before(:each) do
      allow(enc_dump).to receive(:timestamped_name).and_return('timestamped_name')
      allow(Net::FTP).to receive(:new).and_return(mock)
    end

    it do
      expect_any_instance_of(PgExport::Bash::Factory).to receive(:build_dump).and_return(sql_dump)
      expect_any_instance_of(PgExport::Aes::Encryptor).to receive(:call).with(sql_dump).and_return(enc_dump)
      expect_any_instance_of(PgExport::Ftp::Repository).to receive(:persist).with(enc_dump)
      expect_any_instance_of(PgExport::Ftp::Repository).to receive(:remove_old)
      subject
    end
  end
end
