require 'spec_helper'
require 'pg'

describe PgExport::CreateDump do
  let(:database) { 'pg_ftp_backup_database' }
  let(:dump) { PgExport::Dump.new(database, 'spec/tmp/dumps') }
  let(:fake_dump) { PgExport::Dump.new('non_existing_database', 'spec/tmp/dumps') }

  before(:each) do
    begin
      PG.connect(dbname: 'postgres').exec("CREATE DATABASE #{database}")
    rescue PG::DuplicateDatabase
    end
  end

  describe '#call' do
    context 'when specified database does not exist' do
      subject { PgExport::CreateDump.new(fake_dump) }
      it { expect { subject.call }.to raise_error(PgExport::DatabaseDoesNotExistError) }
    end

    context 'when specified database exists' do
      subject { PgExport::CreateDump.new(dump) }
      after(:each) do
        File.delete(dump.pathname)
      end

      it { expect { subject.call }.not_to raise_error }
      it 'should create a dumpfile' do
        expect { subject.call }.to change { File.exist?(dump.pathname) }.from(false).to(true)
      end
    end
  end
end
