require 'null_logger'
require 'pg_export/aes'

RSpec.describe PgExport::Aes::Decryptor do
  let(:decryptor) { PgExport::Aes::Decryptor.new(key: encryption_key, logger: NullLogger) }
  let(:encryption_key) { '1234567890abcdef' }

  let(:encrypted_dump) do
    PgExport::Dump.new(name: 'Plain Dump', db_name: 'database').tap do |dump|
      dump.open(:write) { |f| f << "\u0000\x8A0\xF1\ecW,-\xA1\xFA\xD6{\u0018\xEBf" }
    end
  end

  describe '#call' do
    subject { decryptor.call(encrypted_dump) }

    it { expect(subject.name).to eq('Dump') }
    it { expect(subject.read).to eq('abc') }
  end
end
