require 'dry-struct'

class PgExport
  class Configuration < Dry::Struct
    include Dry::Types.module

    attribute :database,            Strict::String
    attribute :keep_dumps,          Strict::Int
    attribute :dump_encryption_key, Strict::String.constrained(size: 16)
    attribute :ftp_host,            Strict::String
    attribute :ftp_user,            Strict::String
    attribute :ftp_password,        Strict::String
    attribute :logger_format,       Strict::Symbol.enum(:plain, :timestamped, :muted)
  end
end
