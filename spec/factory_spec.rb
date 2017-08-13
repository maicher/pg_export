require 'pg'
require 'null_logger'
require 'pg_export/factory'

RSpec.describe PgExport::Factory do
  let(:factory) { PgExport::Factory.new(logger: NullLogger) }

  describe '#create_dump' do
    subject { factory.build_dump(database) }

    context 'when specified database does not exist' do
      let(:database) { 'pg_export_not_existing_database' }
      it { expect { subject }.to raise_error(PgExport::PgDumpError) }
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
      it { expect(subject).to be_a PgExport::Dump }
      it { expect(subject.name).to eq('Dump') }
    end
  end
end
