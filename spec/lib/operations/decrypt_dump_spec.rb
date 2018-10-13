# frozen_string_literal: true

require 'null_logger'
require 'ostruct'
require 'pg_export/lib/pg_export/factories/cipher_factory'
require 'pg_export/lib/pg_export/operations/decrypt_dump'

RSpec.describe PgExport::Operations::DecryptDump do
  let(:decrypt_dump) { PgExport::Operations::DecryptDump.new(cipher_factory: cipher_factory, logger: NullLogger) }
  let(:cipher_factory) { PgExport::Factories::CipherFactory.new(config: OpenStruct.new(dump_encryption_key: encryption_key)) }
  let(:encryption_key) { '1234567890abcdef' }

  let(:encrypted_dump) do
    PgExport::Entities::Dump.new(name: 'Plain Dump', db_name: 'database').tap do |dump|
      dump.open(:write) { |f| f << "\u0000\x8A0\xF1\ecW,-\xA1\xFA\xD6{\u0018\xEBf" }
    end
  end

  describe '#call' do
    subject { decrypt_dump.call(encrypted_dump) }

    it { expect(subject.name).to eq('Dump') }
    it { expect(subject.read).to eq('abc') }
  end
end
