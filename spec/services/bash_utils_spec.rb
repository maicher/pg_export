require 'pg'
require 'null_logger'
require 'pg_export/factory'
require 'pg_export/services/bash_utils'

RSpec.describe PgExport::BashUtils do
  let!(:postgres_conn) { PG.connect(dbname: 'postgres') }
  let(:dump_encryption_key) { '1234567890abcdef' }
  let(:utils) { PgExport::BashUtils.new(database_name: database, logger: NullLogger) }

  describe '#restore_dump' do
    let(:database_from) { 'pg_export_database_test_1' }
    let(:database_to) { 'pg_export_database_test_2' }
    let(:database_from_conn) { PG.connect(dbname: database_from) }
    let(:database_to_conn) { PG.connect(dbname: database_to) }
    let(:database) { database_from }
    let(:dump) { PgExport::Factory.new(logger: NullLogger).build_dump(database) }
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
      subject { utils.restore_dump(dump, 'pg_export_not_existing_database') }
      it { expect { subject }.to raise_error(PgExport::PgRestoreError) }
    end

    context 'when specified database exists' do
      subject! { utils.restore_dump(dump, database_to) }
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
end
