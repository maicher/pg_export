# frozen_string_literal: true

require 'optparse'
require 'pg_export/configuration'

class PgExport
  class ConfigurationParser
    class Error < OptionParser::ParseError; end

    class << self
      def parse
        h = {
          encryption_key: ENV['PG_EXPORT_ENCRYPTION_KEY'],
          encryption_algorithm: ENV['PG_EXPORT_ENCRYPTION_ALGORITHM'],
          gateway_user: ENV['PG_EXPORT_GATEWAY_USER'],
          gateway_host: ENV['PG_EXPORT_GATEWAY_HOST'],
          gateway_password: ENV['PG_EXPORT_GATEWAY_PASSWORD'],
          logger_format: ENV['PG_EXPORT_LOGGER_FORMAT'],
          keep_dumps: ENV['PG_EXPORT_KEEP_DUMPS'],
          gateway: ENV['PG_EXPORT_GATEWAY'],
          database: ENV['PG_EXPORT_DATABASE'],
          mode: ENV['PG_EXPORT_MODE'],
          command: :export_dump
        }

        option_parser(h).parse!
        h[:database] = ARGV.first unless ARGV.empty?

        Configuration.new(**h)
      rescue OptionParser::ParseError => e
        error = Error.new(*e.args)
        error.reason = e.reason
        raise error
      end

      def help
        option_parser.to_s
      end

      BANNER = <<~TXT
        NAME
            pg_export - CLI for exporting/importing PostgreSQL dumps via FTP/SSH

        SYNOPSIS
            pg_export DATABASE [OPTION..]
            pg_export --interactive DATABASE [OPTION..]

        EXIT VALUES
            0 - Success
            1 - Error

        ARGUMENTS
            DATABASE - database name to export (when default mode)
                     - phrase to filter database dumps by (when interactive mode)

        OPTIONS
      TXT

      EXAMPLE = <<~TXT
        ENV
          Each of the above options can be also set using enviromental variables.
          Use full option names prepending with PG_EXPORT_ phrase.
          Command line options takes precedence over the ENVs.

          Eg. commands:
            pg_export -s -U user -H host database_name -k 10

          Is equivalent to:
            export PG_EXPORT_GATEWAY_USER=user
            export PG_EXPORT_GATEWAY_HOST=host
            export PG_EXPORT_KEEP=20
            pg_export -s database_name -k 10
      TXT

      N = "\n                                     "

      O = {
        g: 'Allowed values: ftp, ssh. Default: ftp',
        U: 'Gateway (ftp or ssh) user',
        H: 'Gateway (ftp or ssh) host',
        P: 'Gateway (ftp or ssh) password',
        d: "In plain mode: database name to export;#{N}In interactive mode: phrase to filter by",
        e: 'Dumps will be SSL encrypted using this key. Should have exactly 16 characters',
        a: "Encryption cipher algorithm (default: AES-128-CBC);#{N}For available option see `$ openssl list -cipher-algorithms`",
        k: 'Number of dump files to keep on FTP/SSH (default: 10)',
        s: 'Same as "--gateway ssh". When set, the --gateway option is ignored',
        f: 'Same as "--gateway ftp". When set, the --gateway option is ignored',
        t: 'Prepends log messages with timestamps',
        m: 'Mutes log messages. When set, the -t option is ignored. Prints message only on error',
        i: 'Interactive mode, for importing dumps. Whan set, the -t and -m options are ignored',
        w: 'Try connecting to the gateway (FTP or SSH) to verify the connection and exit',
        c: 'Print the configuration and exit',
        v: 'Print version',
        h: 'Print this message and exit'
      }.freeze
      private_constant :BANNER, :EXAMPLE, :N, :O

      def option_parser(h = {})
        OptionParser.new do |o|
          o.banner = BANNER
          o.program_name = 'pg_export'
          o.version = PgExport::VERSION
          o.on('-g', '--gateway GATEWAY', %w[ftp ssh], O[:g]) { |v| h[:gateway] = v }
          o.on('-U', '--user USER',            String, O[:U]) { |v| h[:gateway_user] = v }
          o.on('-H', '--host HOST',            String, O[:H]) { |v| h[:gateway_host] = v }
          o.on('-P', '--password PASSWORD',    String, O[:P]) { |v| h[:gateway_password] = v }
          o.on('-d', '--database DATABASE',    String, O[:d]) { |v| h[:database] = v }
          o.on('-e', '--encryption_key KEY',   String, O[:e]) { |v| h[:encryption_key] = v }
          o.on('-a', '--algorithm ALGORITHM',  String, O[:a]) { |v| h[:encryption_algorithm] = v }
          o.on('-k', '--keep KEEP',           Integer, O[:k]) { |v| h[:keep_dumps] = v }
          o.on('-s', '--ssh',                          O[:s]) { h[:gateway] = 'ssh' }
          o.on('-f', '--ftp',                          O[:f]) { h[:gateway] = 'ftp' }
          o.on('-t', '--timestamped',                  O[:t]) { h[:logger_format] = 'timestamped' }
          o.on('-m', '--muted',                        O[:m]) { h[:logger_format] = 'muted' }
          o.on('-i', '--interactive',                  O[:i]) { h[:command] = :import_dump_interactively }
          o.on('-w', '--welcome',                      O[:w]) { h[:command] = :gateway_welcome }
          o.on('-c', '--configuration',                O[:c]) { h[:command] = :print_configuration }
          o.on('-v', '--version',                      O[:v]) { h[:command] = :print_version }
          o.on('-h', '--help',                         O[:h]) { h[:command] = :print_help }
          o.separator ''
          o.separator EXAMPLE
        end
      end
    end
  end
end
