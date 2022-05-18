# frozen_string_literal: true

require 'net/ftp'
require 'net/ssh'
require 'pg_export'
require 'ftp_mock'
require 'ssh_mock'

require 'pg_export/gateways/ftp'
require 'pg_export/gateways/ssh'

describe PgExport do
  it 'has a version number' do
    expect(PgExport::VERSION).not_to be nil
  end

  describe '#call' do
    subject { described_class.new(config).call }

    let(:config) do
      PgExport::Configuration.new(
        encryption_key: '1234567890abcdef',
        encryption_algorithm: 'AES-128-CBC',
        gateway_host: 'example.com',
        gateway_user: 'user',
        gateway_password: 'pass',
        mode: 'plain',
        logger_format: 'muted',
        keep_dumps: 10,
        gateway: gateway,
        database: database
      )
    end

    before do
      allow(dump).to receive(:name).and_return('name')
      allow(dump).to receive(:encrypt)
      allow(dump).to receive(:file)
      allow(dump).to receive(:database).and_return('some_database')
    end

    let(:dump) { Object.new }

    context 'with FTP gateway' do
      let(:gateway) { :ftp }

      before(:each) do
        allow(Net::FTP).to receive(:new).and_return(FtpMock.new)
      end

      context 'when arguments are valid' do
        let(:database) { 'some_database' }

        it 'creates dump and exports it to ftp' do
          expect_any_instance_of(PgExport::Adapters::ShellAdapter).to receive(:pg_dump)
          expect_any_instance_of(PgExport::Factories::DumpFactory).to receive(:plain).and_return(dump)
          expect_any_instance_of(PgExport::Gateways::Ftp).to receive(:persist)
          expect_any_instance_of(PgExport::Gateways::Ftp).to receive(:list).and_return([{ name: 'db_20151010_121212', size: '123' }] * 11)
          expect_any_instance_of(PgExport::Gateways::Ftp).to receive(:delete).with('db_20151010_121212')
          subject
        end
      end

      context 'when argument is invalid' do
        context 'when database is nil' do
          let(:database) { nil }

          it { expect(subject).to be_a(PgExport::ValueObjects::Failure) }
        end

        context 'when database is empty string' do
          let(:database) { '' }

          it { expect(subject).to be_a(PgExport::ValueObjects::Failure) }
        end
      end
    end

    context 'with SSH gateway' do
      let(:gateway) { :ssh }

      before(:each) do
        allow(Net::SSH).to receive(:start).and_return(SshMock.new)
      end

      context 'when arguments are valid' do
        let(:database) { 'some_database' }

        it 'creates dump and exports it to ssh' do
          expect_any_instance_of(PgExport::Adapters::ShellAdapter).to receive(:pg_dump)
          expect_any_instance_of(PgExport::Factories::DumpFactory).to receive(:plain).and_return(dump)
          expect_any_instance_of(PgExport::Gateways::Ssh).to receive(:persist)
          expect_any_instance_of(PgExport::Gateways::Ssh).to receive(:list).and_return([{ name: 'db_20151010_121212', size: '123' }] * 11)
          expect_any_instance_of(PgExport::Gateways::Ssh).to receive(:delete).with('db_20151010_121212')
          subject
        end
      end

      context 'when argument is invalid' do
        context 'when database is nil' do
          let(:database) { nil }

          it { expect(subject).to be_a(PgExport::ValueObjects::Failure) }
        end

        context 'when database is empty string' do
          let(:database) { '' }

          it { expect(subject).to be_a(PgExport::ValueObjects::Failure) }
        end
      end
    end
  end
end
