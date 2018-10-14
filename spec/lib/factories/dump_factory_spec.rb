# frozen_string_literal: true

require 'pg_export/lib/pg_export/factories/dump_factory'
require 'null_logger'

RSpec.describe PgExport::Factories::DumpFactory do
  let(:mock) { Object.new }
  let(:factory) { described_class.new(bash_adapter: mock, logger: NullLogger) }

  describe '#from_database' do
    subject { factory.from_database(database) }
    let(:database) { 'pg_export_database_test' }

    before { allow(mock).to receive(:pg_dump) }

    it { expect { subject }.not_to raise_error }
    it { expect(subject).to be_a PgExport::Entities::Dump }
    it { expect(subject.name).to eq('Dump') }
  end
end
