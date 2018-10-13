# frozen_string_literal: true

require 'pg'
require 'pg_export/factories/dump_factory'
require 'pg_export/repositories/bash_repository'
require 'null_logger'

RSpec.describe PgExport::Repositories::BashRepository do
  let!(:postgres_conn) { PG.connect(dbname: 'postgres') }
  let(:dump_encryption_key) { '1234567890abcdef' }
  let(:repository) { described_class.new }

  describe '#persist' do
    let(:database_from) { 'pg_export_database_test_1' }
    let(:database_to) { 'pg_export_database_test_2' }
    let(:database_from_conn) { PG.connect(dbname: database_from) }
    let(:database_to_conn) { PG.connect(dbname: database_to) }
    let(:database) { database_from }
    let(:dump) { PgExport::Factories::DumpFactory.new(bash_repository: repository, logger: NullLogger).dump_from_database(database) }
    before(:each) do
      postgres_conn.exec("CREATE DATABASE #{database_from}")
      postgres_conn.exec("CREATE DATABASE #{database_to}")
      c = PG.connect(dbname: database_from)
      c.exec('CREATE TABLE IF NOT EXISTS a_table (a_column VARCHAR)')
      c.close
    end
    after(:each) do
      database_from_conn.close
      database_to_conn.close
      postgres_conn.exec("DROP DATABASE IF EXISTS #{database_from}")
      postgres_conn.exec("DROP DATABASE IF EXISTS #{database_to}")
    end

    context 'when specified database does not exist' do
      subject { repository.persist(dump.path, 'pg_export_not_existing_database') }
      it { expect { subject }.to raise_error(PgExport::Repositories::BashRepository::PgPersistError) }
    end

    context 'when specified database exists' do
      subject! { repository.persist(dump.path, database_to) }
      it { expect { subject }.not_to raise_error }

      it 'doesn\'t copy not existing table' do
        expect { database_from_conn.exec('SELECT * FROM not_existing_table') }.to raise_error(PG::UndefinedTable)
        expect { database_to_conn.exec('SELECT * FROM not_existing_table') }.to raise_error(PG::UndefinedTable)
        subject
      end

      it 'copies existing table' do
        expect { database_from_conn.exec('SELECT * FROM a_table') }.not_to raise_error
        expect { database_to_conn.exec('SELECT * FROM a_table') }.not_to raise_error
        subject
      end
    end
  end

  describe '#get' do
    let(:file) { Tempfile.new('test') }
    subject { repository.get(file.path, database) }

    context 'when specified database does not exist' do
      let(:database) { 'pg_export_not_existing_database' }
      it { expect { subject }.to raise_error(PgExport::Repositories::BashRepository::PgDumpError) }
    end

    context 'when specified database exists' do
      let(:database) { 'pg_export_database_test' }
      let(:postgres_conn) { PG.connect(dbname: 'postgres') }
      let(:database_conn) { PG.connect(dbname: database) }

      before { postgres_conn.exec("CREATE DATABASE #{database}") }
      after do
        database_conn.close
        postgres_conn.exec("DROP DATABASE #{database}")
      end

      it { expect { subject }.not_to raise_error }
      it { expect { subject }.to change(file, :size) }
    end
  end
end
