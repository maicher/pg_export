# frozen_string_literal: true

require 'null_logger'
require 'pg_export/factories/cipher_factory'
require 'pg_export/operations/decrypt_dump'
require 'pg_export/operations/copy_dump'

RSpec.describe PgExport::Operations::DecryptDump do
  let(:copy_dump) { PgExport::Operations::CopyDump.new(logger: NullLogger) }
  let(:decryptor) { PgExport::Operations::DecryptDump.new(cipher_factory: cipher_factory, copy_dump: copy_dump) }
  let(:cipher_factory) { PgExport::Factories::CipherFactory.new(config: OpenStruct.new(dump_encryption_key: encryption_key)) }
  let(:encryption_key) { '1234567890abcdef' }

  let(:encrypted_dump) do
    PgExport::ValueObjects::Dump.new(name: 'Plain Dump', db_name: 'database').tap do |dump|
      dump.open(:write) { |f| f << "\u0000\x8A0\xF1\ecW,-\xA1\xFA\xD6{\u0018\xEBf" }
    end
  end

  describe '#call' do
    subject { decryptor.call(encrypted_dump) }

    it { expect(subject.name).to eq('Dump') }
    it { expect(subject.read).to eq('abc') }
  end
end
