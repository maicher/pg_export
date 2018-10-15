# frozen_string_literal: true

require 'net/ftp'
require 'pg_export'
require 'pg_export/container'
require 'pg_export/lib/pg_export/repositories/ftp_dump_repository'
require 'ftp_mock'

describe PgExport do
  before do
    ENV['DUMP_ENCRYPTION_KEY'] = '1234567890abcdef'
    ENV['BACKUP_FTP_HOST'] = 'ftp.example.com'
    ENV['BACKUP_FTP_USER'] = 'user'
    ENV['BACKUP_FTP_PASSWORD'] = 'pass'
    ENV['LOGGER_FORMAT'] = 'muted'
    ENV['INTERACTIVE'] = 'false'
    ENV['KEEP_DUMPS'] = '10'
  end
  let!(:pg_export) { PgExport.plain }

  it 'has a version number' do
    expect(PgExport::VERSION).not_to be nil
  end

  describe '#call' do
    subject { pg_export.call(database) }
    let(:mock) { FtpMock.new }
    let(:dump) { Object.new }

    before(:each) do
      allow(dump).to receive(:name).and_return('name')
      allow(dump).to receive(:encrypt)
      allow(Net::FTP).to receive(:new).and_return(mock)
    end

    context 'when arguments are valid' do
      let(:database) { 'some_database' }

      it 'creates dump and exports it to ftp' do
        expect_any_instance_of(PgExport::Adapters::BashAdapter).to receive(:pg_dump)
        expect_any_instance_of(PgExport::Factories::DumpFactory).to receive(:plain).and_return(dump)
        expect_any_instance_of(PgExport::Repositories::FtpDumpRepository).to receive(:persist).with(dump)
        expect_any_instance_of(PgExport::Repositories::FtpDumpRepository).to receive(:by_name).and_return(['a'] * 11)
        expect_any_instance_of(PgExport::Repositories::FtpDumpRepository).to receive(:delete).with('a')
        subject
      end
    end

    context 'when argument is invalid' do
      context 'when database is nil' do
        let(:database) { nil }

        it { expect(subject).to be_a(Dry::Monads::Result::Failure) }
      end

      context 'when database is empty string' do
        let(:database) { '' }

        it { expect(subject).to be_a(Dry::Monads::Result::Failure) }
      end
    end
  end
end
