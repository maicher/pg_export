require 'spec_helper'

RSpec.describe PgExport::Utils do
  let(:dump_encryption_key) { '1234567890abcdef' }
  subject { PgExport::Utils.new(PgExport::Aes.encryptor(dump_encryption_key), PgExport::Aes.decryptor(dump_encryption_key)) }

  describe '.create_dump' do
    let(:database) { 'pg_export_database_test' }
    before(:each) do
      begin
        PG.connect(dbname: 'postgres').exec("CREATE DATABASE #{database}")
      rescue PG::DuplicateDatabase
      end
    end

    context 'when specified database does not exist' do
      it { expect { subject.create_dump('non_existing_database_name') }.to raise_error(PgExport::PgDumpError) }
    end

    context 'when specified database exists' do
      it { expect { subject.create_dump(database) }.not_to raise_error }
      it { expect(subject.create_dump(database)).to be_a PgExport::SqlDump }
    end
  end

  describe '.encrypt' do
    let(:sql_dump) { d = PgExport::SqlDump.new; d.open(:write) { |f| f << 'abc' }; d }

    it { expect(subject.encrypt(sql_dump)).to be_a PgExport::EncryptedDump }
    it { expect(subject.encrypt(sql_dump).read).not_to eq('abc') }
  end

  describe '.decrypt' do
    let(:sql_dump) { d = PgExport::SqlDump.new; d.open(:write) { |f| f << 'abc' }; d }
    let(:enc_dump) { subject.encrypt(sql_dump) }

    it { expect(subject.decrypt(enc_dump)).to be_a PgExport::SqlDump }
    it { expect(subject.decrypt(enc_dump).read).to eq('abc') }
  end
end
