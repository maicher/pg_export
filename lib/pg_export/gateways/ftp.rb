# frozen_string_literal: true

require 'net/ftp'

class PgExport
  module Gateways
    class Ftp
      CHUNK_SIZE = (2**16)

      def initialize(host:, user:, password:)
        @host, @user, @password, @logger = host, user, password
      end

      def open
        @ftp = Net::FTP.new(host, user, password)
        @ftp.passive = true
        @ftp
      end

      def welcome
        open.welcome
      end

      def close
        @ftp&.close
      end

      def list(name)
        ftp
          .list([name, '*'].join('_'))
          .map { |row| extracted_meaningful_attributes(row) }
          .sort_by { |item| item[:name] }
          .reverse
      end

      def delete(name)
        ftp.delete(name)
      end

      def persist(file, name)
        ftp.putbinaryfile(file.path, name, CHUNK_SIZE)
      end

      def get(file, name)
        ftp.getbinaryfile(name, file.path, CHUNK_SIZE)
      end

      def to_s
        host
      end

      def ftp
        @ftp ||= open
      end

      private

      attr_reader :host, :user, :password

      def extracted_meaningful_attributes(item)
        MEANINGFUL_KEYS.zip(item.split(' ').values_at(8, 4)).to_h
      end

      MEANINGFUL_KEYS = %i[name size].freeze
      private_constant :MEANINGFUL_KEYS
    end
  end
end
