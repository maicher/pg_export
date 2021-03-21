# frozen_string_literal: true

require 'ostruct'
require 'pg_export/lib/pg_export/factories/cipher_factory'
require 'pg_export/lib/pg_export/operations/decrypt_dump'
require 'pg_export/lib/pg_export/value_objects/dump_file'

RSpec.describe PgExport::Operations::DecryptDump do
  let(:decrypt_dump) { PgExport::Operations::DecryptDump.new(cipher_factory: cipher_factory) }
  let(:cipher_factory) { PgExport::Factories::CipherFactory.new(config: OpenStruct.new(encryption_key: encryption_key, encryption_algorithm: encryption_algorithm)) }
  let(:encryption_key) { '1234567890abcdef' }
  let(:encryption_algorithm) { 'AES-128-CBC' }

  let(:encrypted_dump) do
    file = PgExport::ValueObjects::DumpFile.new
    file.write { |f| f << "\u0000\x8A0\xF1\ecW,-\xA1\xFA\xD6{\u0018\xEBf" }
    file.rewind
    PgExport::Entities::Dump.new(name: 'datbase_20180101_121212', database: 'database', file: file, type: :encrypted)
  end

  describe '#call' do
    subject { decrypt_dump.call(dump: encrypted_dump) }

    it { expect(subject.success[:dump].name).to eq('datbase_20180101_121212') }
    it { expect(subject.success[:dump].file.read).to eq('abc') }
  end
end
