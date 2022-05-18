# frozen_string_literal: true

require 'pg_export/factories/cipher_factory'
require 'pg_export/value_objects/dump_file'
require 'pg_export/entities/dump'
require 'pg_export/operations/encrypt_dump'

RSpec.describe PgExport::Operations::EncryptDump do
  let(:encrypt_dump) { PgExport::Operations::EncryptDump.new(cipher_factory: cipher_factory) }
  let(:cipher_factory) { PgExport::Factories::CipherFactory.new(encryption_key: key, encryption_algorithm: alg) }
  let(:key) { '1234567890abcdef' }
  let(:alg) { 'AES-128-CBC' }

  let(:plain_dump) do
    file = PgExport::ValueObjects::DumpFile.new
    file.write { |f| f << 'abc' }
    file.rewind
    PgExport::Entities::Dump.new(name: 'datbase_20180101_121212', database: 'database', file: file, type: :plain)
  end

  describe '#call' do
    subject { encrypt_dump.call(dump: plain_dump) }

    it { expect(subject.success[:dump].name).to eq('datbase_20180101_121212') }
    it { expect(subject.success[:dump].file.read).to eq("\u0000\x8A0\xF1\ecW,-\xA1\xFA\xD6{\u0018\xEBf") }
  end
end
