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
      it { expect(subject.create_dump(database)).to be_a PgExport::PlainDump }
    end
  end

  describe '.encrypt' do
    let(:plain_dump) do
      d = PgExport::PlainDump.new
      d.open(:write) { |f| f << 'abc' }
      d
    end

    it { expect(subject.encrypt(plain_dump)).to be_a PgExport::EncryptedDump }
    it { expect(subject.encrypt(plain_dump).read).not_to eq('abc') }
  end

  describe '.decrypt' do
    let(:plain_dump) do
      d = PgExport::PlainDump.new
      d.open(:write) { |f| f << 'abc' }
      d
    end
    let(:enc_dump) { subject.encrypt(plain_dump) }

    it { expect(subject.decrypt(enc_dump)).to be_a PgExport::PlainDump }
    it { expect(subject.decrypt(enc_dump).read).to eq('abc') }
  end
end
