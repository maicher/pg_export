# frozen_string_literal: true

require 'pg_export'
require 'ftp_mock'

describe PgExport do
  before do
    ENV['DUMP_ENCRYPTION_KEY'] = '1234567890abcdef'
    ENV['FTP_HOST'] = 'ftp.example.com'
    ENV['FTP_USER'] = 'user'
    ENV['FTP_PASSWORD'] = 'pass'
    ENV['LOGGER_FORMAT'] = 'muted'
    ENV['INTERACTIVE'] = 'false'
  end
  let(:pg_export) { PgExport.plain }

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
      it { expect { subject }.to raise_error(PgExport::InitializationError) }
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

        it { expect(subject).to be_a(Dry::Monads::Result::Failure) }
      end

      context 'when database is empty string' do
        let(:database) { '' }
        let(:keep_dumps) { 10 }

        it { expect(subject).to be_a(Dry::Monads::Result::Failure) }
      end

      context 'when keep_dumps nil' do
        let(:database) { 'a_database' }
        let(:keep_dumps) { nil }

        it { expect(subject).to be_a(Dry::Monads::Result::Failure) }
      end

      context 'when keep_dumps is negative' do
        let(:database) { 'a_database' }
        let(:keep_dumps) { -10 }

        it { expect(subject).to be_a(Dry::Monads::Result::Failure) }
      end

      context 'when keep_dumps is not numeric' do
        let(:database) { 'a_database' }
        let(:keep_dumps) { 'something' }

        it { expect(subject).to be_a(Dry::Monads::Result::Failure) }
      end
    end
  end
end
