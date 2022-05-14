# frozen_string_literal: true

class PgExport
  class Configuration
    ATTRS = %i[
      encryption_key
      encryption_algorithm
      gateway_host
      gateway_user
      gateway_password
      logger_format
      keep_dumps
      gateway mode
    ]

    attr_reader *ATTRS

    def self.build(env)
      new(
        encryption_key: env['PG_EXPORT_ENCRYPTION_KEY'],
        encryption_algorithm: env['PG_EXPORT_ENCRYPTION_ALGORITHM'],
        gateway_host: env['PG_EXPORT_GATEWAY_HOST'],
        gateway_user: env['PG_EXPORT_GATEWAY_USER'],
        gateway_password: env['PG_EXPORT_GATEWAY_PASSWORD'],
        logger_format: env['LOGGER_FORMAT'],
        keep_dumps: env['KEEP_DUMPS'],
        gateway: env['GATEWAY'],
        mode: env['PG_EXPORT_MODE']
      )
    end

    def initialize(
      encryption_key: nil,
      encryption_algorithm: nil,
      gateway_host: nil,
      gateway_user: nil,
      gateway_password: nil,
      logger_format: nil,
      keep_dumps: nil,
      gateway: nil,
      mode: nil
    )

      @encryption_key = String(encryption_key)
      raise ArgumentError, 'Encryption key must be 16 chars long' if @encryption_key.length != 16

      @encryption_algorithm = String(encryption_algorithm)
      @encryption_algorithm = 'AES-128-CBC' if @encryption_algorithm.empty?

      @gateway_host = String(gateway_host)
      raise ArgumentError, 'Gatway host must not be empty' if @gateway_host.empty?

      @gateway_user = String(gateway_user)
      raise ArgumentError, 'Gatway user must not be empty' if @gateway_user.empty?

      @gateway_password = nil if gateway_password.nil? || gateway_password.to_s.empty?

      @logger_format = logger_format.to_s.to_sym
      @logger_format = :plain if @logger_format.empty?
      raise ArgumentError, 'Logger format must be one of: plain, timestamped, muted' unless %i[plain timestamped muted].include?(@logger_format)

      @keep_dumps = Integer(keep_dumps || 10)
      raise ArgumentError, 'Keep dumps must greater or equal to 1' unless @keep_dumps >= 1

      @gateway = gateway.to_s.to_sym
      @gateway = :ftp if @gateway.empty?
      raise ArgumentError, 'Gateway must be one of: ftp, ssh' unless %i[ftp ssh].include?(@gateway)

      @mode = mode.to_s.to_sym
      @mode = :plain if @mode.empty?
      raise ArgumentError, 'Mode must be one of: plain, interactive' unless %i[plain interactive].include?(@mode)
    end

    def to_s
      ATTRS.map do |name|
        value = public_send(name)

        if [:encryption_key, :gateway_password].include?(name)
          "  #{name} #{value.nil? ? '' : value[0..2] + '***' }"
        else
          "  #{name} #{value}"
        end
      end.join("\n")
    end
  end
end
