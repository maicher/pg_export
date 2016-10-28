require 'spec_helper'

RSpec.describe PgExport::Utils do
  let!(:postgres_conn) { PG.connect(dbname: 'postgres') }
  let(:dump_encryption_key) { '1234567890abcdef' }
  let!(:utils) { PgExport::Utils.new(PgExport::Aes.encryptor(dump_encryption_key), PgExport::Aes.decryptor(dump_encryption_key)) }

  describe '.create_dump' do
    let(:database) { 'pg_export_database_test' }
    let(:database_conn) { PG.connect(dbname: database) }
    before(:each) { postgres_conn.exec("CREATE DATABASE #{database}") }
    after(:each) do
      database_conn.close
      postgres_conn.exec("DROP DATABASE #{database}")
    end

    context 'when specified database does not exist' do
      subject { utils.create_dump('pg_export_not_existing_database') }
      it { expect { subject }.to raise_error(PgExport::PgDumpError) }
    end

    context 'when specified database exists' do
      subject { utils.create_dump(database) }
      it { expect { subject }.not_to raise_error }
      it { expect(subject).to be_a PgExport::PlainDump }
    end
  end

  describe '.restore_dump' do
    let(:database_from) { 'pg_export_database_test_1' }
    let(:database_to) { 'pg_export_database_test_2' }
    let(:database_from_conn) { PG.connect(dbname: database_from) }
    let(:database_to_conn) { PG.connect(dbname: database_to) }
    let(:dump) { utils.create_dump(database_from) }
    before(:each) do
      postgres_conn.exec("CREATE DATABASE #{database_from}")
      postgres_conn.exec("CREATE DATABASE #{database_to}")
      database_from_conn.exec("CREATE TABLE IF NOT EXISTS a_table (a_column VARCHAR)")
    end
    after(:each) do
      database_from_conn.close
      database_to_conn.close
      postgres_conn.exec("DROP DATABASE IF EXISTS #{database_from}")
      postgres_conn.exec("DROP DATABASE IF EXISTS #{database_to}")
    end

    context 'when specified database does not exist' do
      subject{ utils.restore_dump(dump, 'pg_export_not_existing_database') }
      it { expect { subject }.to raise_error(PgExport::PgRestoreError) }
    end

    context 'when specified database exists' do
      subject{ utils.restore_dump(dump, database_to) }
      it { expect { subject }.not_to raise_error }

      it { expect{subject; database_from_conn.exec("SELECT * FROM not_existing_table")}.to raise_error(PG::UndefinedTable) }
      it { expect{subject; database_from_conn.exec("SELECT * FROM a_table")}.not_to raise_error }
      it { expect{subject; database_to_conn.exec("SELECT * FROM not_existing_table")}.to raise_error(PG::UndefinedTable) }
      it { expect{subject; database_to_conn.exec("SELECT * FROM a_table")}.not_to raise_error }
    end
  end

  describe '.encrypt' do
    let(:plain_dump) do
      d = PgExport::PlainDump.new
      d.open(:write) { |f| f << 'abc' }
      d
    end
    subject { utils.encrypt(plain_dump) }

    it { expect(subject).to be_a PgExport::EncryptedDump }
    it { expect(subject.read).not_to eq('abc') }
  end

  describe '.decrypt' do
    let(:plain_dump) do
      d = PgExport::PlainDump.new
      d.open(:write) { |f| f << 'abc' }
      d
    end
    let(:enc_dump) { utils.encrypt(plain_dump) }
    subject { utils.decrypt(enc_dump) }

    it { expect(subject).to be_a PgExport::PlainDump }
    it { expect(subject.read).to eq('abc') }
  end
end
