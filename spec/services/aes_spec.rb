require 'spec_helper'

RSpec.describe 'Aes' do
  let!(:postgres_conn) { PG.connect(dbname: 'postgres') }
  let(:dump_encryption_key) { '1234567890abcdef' }
  let(:aes) { PgExport::Aes.new(dump_encryption_key) }
  let!(:encryptor) { aes.build_encryptor }
  let!(:decryptor) { aes.build_decryptor }

  describe 'encryptor' do
    let(:plain_dump) do
      d = PgExport::PlainDump.new
      d.open(:write) { |f| f << 'abc' }
      d
    end
    subject { encryptor.call(plain_dump) }

    it { expect(subject).to be_a PgExport::EncryptedDump }
    it { expect(subject.read).not_to eq('abc') }
  end

  describe 'decryptor' do
    let(:plain_dump) do
      d = PgExport::PlainDump.new
      d.open(:write) { |f| f << 'abc' }
      d
    end
    let(:enc_dump) { encryptor.call(plain_dump) }
    subject { decryptor.call(enc_dump) }

    it { expect(subject).to be_a PgExport::PlainDump }
    it { expect(subject.read).to eq('abc') }
  end
end
