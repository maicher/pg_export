# frozen_string_literal: true

require 'dry-initializer'
require 'pg_export/lib/pg_export/types'

class PgExport
  module Entities
    class Dump
      extend Dry::Initializer[undefined: false]

      option :name,     Types::DumpName
      option :type,     Types::DumpType
      option :database, Types::Strict::String.constrained(filled: true)
      option :file,     Types::DumpFile, default: proc { PgExport::ValueObjects::DumpFile.new }

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
        "#{name} (#{file.size_human})"
      end

      def file=(f)
        @file = Types::DumpFile[f]
      end

      protected

      def type=(t)
        @type = Types::DumpType[t]
      end
    end
  end
end
