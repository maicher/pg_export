# frozen_string_literal: true

require 'pg_export/factories/dump_factory'
require 'null_logger'

RSpec.describe PgExport::Factories::DumpFactory do
  let(:mock) { Object.new }
  let(:factory) { described_class.new(bash_repository: mock, logger: NullLogger) }

  describe '#dump_from_database' do
    subject { factory.dump_from_database(database) }
    let(:database) { 'pg_export_database_test' }

    before { allow(mock).to receive(:get) }

    it { expect { subject }.not_to raise_error }
    it { expect(subject).to be_a PgExport::ValueObjects::Dump }
    it { expect(subject.name).to eq('Dump') }
  end
end
