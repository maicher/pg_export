require 'spec_helper'

RSpec.describe 'Encryptor and Decryptor' do
  let!(:postgres_conn) { PG.connect(dbname: 'postgres') }
  let(:dump_encryption_key) { '1234567890abcdef' }
  let!(:encrypt) { PgExport::Encrypt.new(PgExport::Aes.encryptor(dump_encryption_key)) }
  let!(:decrypt) { PgExport::Decrypt.new(PgExport::Aes.decryptor(dump_encryption_key)) }

  describe '.encrypt' do
    let(:plain_dump) do
      d = PgExport::PlainDump.new
      d.open(:write) { |f| f << 'abc' }
      d
    end
    subject { encrypt.call(plain_dump) }

    it { expect(subject).to be_a PgExport::EncryptedDump }
    it { expect(subject.read).not_to eq('abc') }
  end

  describe '.decrypt' do
    let(:plain_dump) do
      d = PgExport::PlainDump.new
      d.open(:write) { |f| f << 'abc' }
      d
    end
    let(:enc_dump) { encrypt.call(plain_dump) }
    subject { decrypt.call(enc_dump) }

    it { expect(subject).to be_a PgExport::PlainDump }
    it { expect(subject.read).to eq('abc') }
  end
end
