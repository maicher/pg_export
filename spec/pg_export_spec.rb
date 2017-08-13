require 'pg_export'
require 'ftp_mock'

describe PgExport do
  let(:database) { 'some_database' }
  let(:keep) { 10 }

  subject { PgExport.new(**params) }

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

  describe '#call' do
    let(:mock) { FtpMock.new }
    let(:sql_dump) { Object.new }
    let(:enc_dump) { Object.new }

    before(:each) do
      allow(Net::FTP).to receive(:new).and_return(mock)
    end

    it do
      expect_any_instance_of(PgExport::Factory).to receive(:build_dump).and_return(sql_dump)
      expect_any_instance_of(PgExport::Aes::Encryptor).to receive(:call).with(sql_dump).and_return(enc_dump)
      expect_any_instance_of(PgExport::Repository).to receive(:upload).with(enc_dump)
      expect_any_instance_of(PgExport::Repository).to receive(:remove_old)
      subject.call
    end
  end
end
