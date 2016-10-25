require 'spec_helper'

describe PgExport::SqlDump do
  subject { PgExport::SqlDump.new }

  it { expect(subject).to be_a(PgExport::Dump::Base) }
end
