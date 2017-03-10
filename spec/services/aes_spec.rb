require 'spec_helper'

RSpec.describe PgExport::Aes do
  let!(:postgres_conn) { PG.connect(dbname: 'postgres') }
  let(:encryption_key) { '1234567890abcdef' }
  let(:aes) { PgExport::Aes.new(encryption_key) }

  describe '#build_encryptor' do
    subject { aes.build_encryptor }
    it { is_expected.to be_a(PgExport::Aes::Encryptor) }
  end

  describe '#build_decryptor' do
    subject { aes.build_decryptor }
    it { is_expected.to be_a(PgExport::Aes::Decryptor) }
  end

  describe PgExport::Aes::Encryptor do
    let(:encryptor) { aes.build_encryptor }
    let(:plain_dump) do
      d = PgExport::PlainDump.new
      d.open(:write) { |f| f << 'abc' }
      d
    end
    subject { encryptor.call(plain_dump) }

    it { expect(subject).to be_a PgExport::EncryptedDump }
    it { expect(subject.read).not_to eq('abc') }
  end

  describe PgExport::Aes::Decryptor do
    let(:encryptor) { aes.build_encryptor }
    let(:decryptor) { aes.build_decryptor }
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
