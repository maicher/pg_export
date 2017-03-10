require 'spec_helper'

describe PgExport::Dump::SizeHuman do
  let(:klass) do
    Class.new do
      include PgExport::Dump::SizeHuman
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
