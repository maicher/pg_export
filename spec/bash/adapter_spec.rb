# frozen_string_literal: true

require 'pg'
require 'pg_export/bash/factory'
require 'pg_export/bash/adapter'
require 'null_logger'

RSpec.describe PgExport::Bash::Adapter do
  let!(:postgres_conn) { PG.connect(dbname: 'postgres') }
  let(:dump_encryption_key) { '1234567890abcdef' }
  let(:adapter) { PgExport::Bash::Adapter.new }

  describe '#persist' do
    let(:database_from) { 'pg_export_database_test_1' }
    let(:database_to) { 'pg_export_database_test_2' }
    let(:database_from_conn) { PG.connect(dbname: database_from) }
    let(:database_to_conn) { PG.connect(dbname: database_to) }
    let(:database) { database_from }
    let(:dump) { PgExport::Bash::Factory.new(bash_adapter: adapter, logger: NullLogger).build_dump(database) }
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
      subject { adapter.persist(dump.path, 'pg_export_not_existing_database') }
      it { expect { subject }.to raise_error(PgExport::Bash::Adapter::PgPersistError) }
    end

    context 'when specified database exists' do
      subject! { adapter.persist(dump.path, database_to) }
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
    subject { adapter.get(file.path, database) }

    context 'when specified database does not exist' do
      let(:database) { 'pg_export_not_existing_database' }
      it { expect { subject }.to raise_error(PgExport::Bash::Adapter::PgDumpError) }
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
