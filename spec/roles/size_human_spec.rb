require 'pg_export/roles/human_readable'

describe PgExport::Roles::HumanReadable do
  let(:klass) do
    Class.new do
      include PgExport::Roles::HumanReadable
      def size
        1024
      end
    end
  end

  subject { klass.new }

  describe '#size_human' do
    it { expect(subject.size_human).to eq('1.0kB') }
  end
end
