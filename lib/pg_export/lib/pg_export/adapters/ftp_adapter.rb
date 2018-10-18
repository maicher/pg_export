# frozen_string_literal: true

# auto_register: false

require 'net/ftp'

class PgExport
  module Adapters
    class FtpAdapter
      CHUNK_SIZE = (2**16).freeze

      def initialize(host:, user:, password:)
        @host, @user, @password, @logger = host, user, password
        ObjectSpace.define_finalizer(self, proc { ftp.close if @ftp })
      end

      def open_ftp
        @ftp = Net::FTP.new(host, user, password)
        @ftp.passive = true
        @ftp
      end

      def close_ftp
        @ftp&.close
      end

      def list(regex_string)
        ftp
          .list(regex_string)
          .map { |row| extracted_meaningful_attributes(row) }
          .sort_by { |item| item[:name] }
          .reverse
      end

      def delete(filename)
        ftp.delete(filename)
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
        @ftp ||= open_ftp
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
