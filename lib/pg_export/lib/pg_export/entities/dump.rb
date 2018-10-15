# frozen_string_literal: true

require 'dry-initializer'
require 'dry-types'

require 'pg_export/lib/pg_export/value_objects/dump_file'

class PgExport
  module Entities
    class Dump
      extend Dry::Initializer[undefined: false]

      TYPE_ENUM_TYPE = Dry::Types['coercible.string'].enum('plain', 'encrypted')
      DUMP_FILE_TYPE = Dry::Types.module.Instance(PgExport::ValueObjects::DumpFile)
      private_constant :TYPE_ENUM_TYPE, :DUMP_FILE_TYPE

      option :name,     Dry::Types['strict.string'].constrained(format: /.+_20[0-9]{6}_[0-9]{6}\Z/)
      option :database, Dry::Types['strict.string'].constrained(filled: true)
      option :type,     TYPE_ENUM_TYPE
      option :file,     DUMP_FILE_TYPE, default: proc { PgExport::ValueObjects::DumpFile.new }

      def encrypt(cipher_factory:)
        self.file = file.copy(cipher: cipher_factory.encryptor)
        self.type = :encrypted

        self
      end

      def decrypt(cipher_factory:)
        self.file = file.copy(cipher: cipher_factory.decryptor)
        self.type = :plain

        self
      end

      def to_s
        "#{type} dump (#{name} - #{file.size_human})"
      end

      protected

      def file=(f)
        @file = DUMP_FILE_TYPE[f]
      end

      def type=(t)
        @type = TYPE_ENUM_TYPE[t]
      end

      TIMESTAMP_FORMAT = '%Y%m%d_%H%M%S'
      private_constant :TIMESTAMP_FORMAT
    end
  end
end
