require 'spec_helper'

RSpec.describe PgExport::Utils do
  subject { PgExport::Utils }

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

  describe '.compress' do
    let(:sql_dump) { PgExport::SqlDump.new }
    before(:each) do
      sql_dump.open(:write) do |f|
        f.write('abc')
      end
    end

    it { expect(subject.compress(sql_dump)).to be_a PgExport::CompressedDump }
    it { expect(subject.compress(sql_dump).read).not_to eq('abc') }
  end

  describe '.decompress' do
    let(:gz_dump) { PgExport::CompressedDump.new }
    before(:each) do
      gz_dump.open(:write) do |gz|
        gz.write('abc')
      end
    end

    it { expect(subject.decompress(gz_dump)).to be_a PgExport::SqlDump }
    it { expect(subject.decompress(gz_dump).read).to eq('abc') }
  end
end
