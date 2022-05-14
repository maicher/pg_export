# frozen_string_literal: true

class PgExport
  module Entities
    class Dump
      attr_reader :name, :type, :database, :file

      def initialize(name: nil, type: nil, database: nil, file: nil)
        @name = String(name)
        raise ArgumentError, 'Dump name must not be empty' if @name.empty?
        raise ArgumentError, 'Dump name does not match criteria' unless /.+_20[0-9]{6}_[0-9]{6}\Z/.match?(@name)

        @type = String(type)
        @type = 'plain' if @type.empty?
        raise ArgumentError, 'Dump type must be one of: plain, encrypted' unless %w[plain encrypted].include?(@type)

        @database = database

        @file = file
        @file = ValueObjects::DumpFile.new if @file.nil?
        raise ArgumentError, "Invalid file type: #{@file.class}" unless @file.is_a?(ValueObjects::DumpFile)
      end

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
        @file = f

        raise ArgumentError, "Invalid file type: '#{f}'" unless @file.is_a?(ValueObjects::DumpFile)
      end

      protected

      def type=(t)
        @type = t.to_s

        raise ArgumentError, "Dump type '#{t}' must be one of: plain, encrypted" unless %w[plain encrypted].include?(@type)
      end
    end
  end
end
