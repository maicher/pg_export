require 'spec_helper'

RSpec.describe PgExport::Aes::Encryptor do
  let(:encryptor) { PgExport::Aes::Encryptor.new(key: encryption_key, logger: NullLogger) }
  let(:encryption_key) { '1234567890abcdef' }

  let(:plain_dump) do
    PgExport::Dump.new('Plain Dump').tap do |dump|
      dump.open(:write) { |f| f << 'abc' }
    end
  end

  describe '#call' do
    subject { encryptor.call(plain_dump) }

    it { expect(subject.name).to eq('Encrypted Dump') }
    it { expect(subject.read).to eq("\u0000\x8A0\xF1\ecW,-\xA1\xFA\xD6{\u0018\xEBf") }
  end
end
