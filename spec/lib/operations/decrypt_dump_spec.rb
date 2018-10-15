# frozen_string_literal: true

require 'null_logger'
require 'ostruct'
require 'pg_export/lib/pg_export/factories/cipher_factory'
require 'pg_export/lib/pg_export/operations/decrypt_dump'
require 'pg_export/lib/pg_export/value_objects/dump_file'

RSpec.describe PgExport::Operations::DecryptDump do
  let(:decrypt_dump) { PgExport::Operations::DecryptDump.new(cipher_factory: cipher_factory, logger: NullLogger) }
  let(:cipher_factory) { PgExport::Factories::CipherFactory.new(config: OpenStruct.new(dump_encryption_key: encryption_key)) }
  let(:encryption_key) { '1234567890abcdef' }

  let(:encrypted_dump) do
    file = PgExport::ValueObjects::DumpFile.new
    file.write { |f| f << "\u0000\x8A0\xF1\ecW,-\xA1\xFA\xD6{\u0018\xEBf" }
    file.rewind
    PgExport::Entities::Dump.new(name: 'datbase_20180101_121212', database: 'database', file: file, type: :encrypted)
  end

  describe '#call' do
    subject { decrypt_dump.call(encrypted_dump) }

    it { expect(subject.name).to eq('datbase_20180101_121212') }
    it { expect(subject.file.read).to eq('abc') }
  end
end
