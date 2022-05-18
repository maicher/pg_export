# frozen_string_literal: true

require 'pg_export/entities/dump'

describe PgExport::Entities::Dump do
  subject do
    PgExport::Entities::Dump.new(
      name: 'database_name_20180101_123222',
      database: 'database_name',
      type: :plain
    )
  end

  it { expect(subject).to respond_to(:encrypt) }
  it { expect(subject).to respond_to(:decrypt) }
  it { expect(subject).to respond_to(:to_s) }
end
