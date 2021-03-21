# frozen_string_literal: true

# auto_register: false

require 'ed25519'
require 'net/ssh'
require 'net/scp'

class PgExport
  module Gateways
    class Ssh
      CHUNK_SIZE = (2**16).freeze

      def initialize(host:, user:, password:)
        @host, @user, @password, @logger = host, user, password
      end

      def open
        if password.nil?
          @ssh = Net::SSH.start(host, user)
        else
          @ssh = Net::SSH.start(host, user, password)
        end
      end

      def welcome
        open.exec!('hostname')
      end

      def close
        @ssh&.close
      end

      def list(name)
        grep =
          if name.nil? || name.empty?
            ''
          else
            " | grep #{name}"
          end

        ssh
          .exec!("ls -l#{grep}")
          .split("\n").map { |row| extract_meaningful_attributes(row) }
          .reject { |item| item[:name].nil? }
          .sort_by { |item| item[:name] }
          .reverse
      end

      def delete(name)
        # @TODO
      end

      def persist(file, name)
        ssh.scp.upload(file.path, name).wait
      end

      def get(file, name)
        ssh.scp.download(name, file.path).wait
      end

      def to_s
        host
      end

      def ssh
        @ssh ||= open
      end

      private

      attr_reader :host, :user, :password

      def extract_meaningful_attributes(item)
        MEANINGFUL_KEYS.zip(item.split(' ').values_at(8, 4)).to_h
      end

      MEANINGFUL_KEYS = %i[name size].freeze
      private_constant :MEANINGFUL_KEYS
    end
  end
end
