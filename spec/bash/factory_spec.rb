# frozen_string_literal: true

require 'pg_export/bash/factory'
require 'null_logger'

RSpec.describe PgExport::Bash::Factory do
  let(:mock) { Object.new }
  let(:factory) { PgExport::Bash::Factory.new(bash_adapter: mock, logger: NullLogger) }

  describe '#build_dump' do
    subject { factory.build_dump(database) }
    let(:database) { 'pg_export_database_test' }

    before { allow(mock).to receive(:get) }

    it { expect { subject }.not_to raise_error }
    it { expect(subject).to be_a PgExport::ValueObjects::Dump }
    it { expect(subject.name).to eq('Dump') }
  end
end
