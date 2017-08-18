require 'pg_export'
require 'ftp_mock'

describe PgExport do
  let(:pg_export) { PgExport.new(**params) }

  let(:params) do
    {
      dump_encryption_key: '1234567890abcdef',
      ftp_host: 'ftp.example.com',
      ftp_user: 'user',
      ftp_password: 'pass',
      logger_format: :muted,
      interactive: false
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
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '#call' do
    subject { pg_export.call(database, keep_dumps) }
    let(:mock) { FtpMock.new }
    let(:sql_dump) { Object.new }
    let(:enc_dump) { Object.new }

    before(:each) do
      allow(enc_dump).to receive(:timestamped_name).and_return('timestamped_name')
      allow(Net::FTP).to receive(:new).and_return(mock)
    end

    context 'when arguments are valid' do
      let(:database) { 'some_database' }
      let(:keep_dumps) { 10 }

      it 'creates dump and exports it to ftp' do
        expect_any_instance_of(PgExport::Bash::Factory).to receive(:build_dump).and_return(sql_dump)
        expect_any_instance_of(PgExport::Aes::Encryptor).to receive(:call).with(sql_dump).and_return(enc_dump)
        expect_any_instance_of(PgExport::Ftp::Repository).to receive(:persist).with(enc_dump)
        expect_any_instance_of(PgExport::Ftp::Repository).to receive(:remove_old)
        subject
      end
    end

    context 'when one of the argument is invalid' do
      context 'when database is nil' do
        let(:database) { nil }
        let(:keep_dumps) { 10 }

        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context 'when database is empty string' do
        let(:database) { '' }
        let(:keep_dumps) { 10 }

        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context 'when database is not string' do
        let(:database) { 234 }
        let(:keep_dumps) { 10 }

        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context 'when keep_dumps nil' do
        let(:database) { 'a_database' }
        let(:keep_dumps) { nil }

        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context 'when keep_dumps is negative' do
        let(:database) { 'a_database' }
        let(:keep_dumps) { -10 }

        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context 'when keep_dumps is not numeric' do
        let(:database) { 'a_database' }
        let(:keep_dumps) { 'something' }

        it { expect { subject }.to raise_error(ArgumentError) }
      end
    end
  end
end
