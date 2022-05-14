# frozen_string_literal: true

require 'pg_export/configuration'

describe PgExport::Configuration do
  subject { PgExport::Configuration.new(**params) }

  let(:valid_params) do
    {
      encryption_key: '1234567890abcdef',
      encryption_algorithm: 'AES-128-CBC',
      gateway_host: 'host',
      gateway_user: 'user',
      gateway_password: 'password',
      logger_format: :plain,
      keep_dumps: '10',
      gateway: :ssh,
      mode: :plain
    }
  end

  describe '.initialize' do
    context 'when all config parameters are provided' do
      let(:params) { valid_params }
      it { expect { subject }.not_to raise_error }
    end

    %i[encryption_key gateway_host gateway_user].each do |param_name|
      context "when #{param_name} parameter is missing" do
        let(:params) { valid_params.tap { |p| p.delete(param_name) } }
        it { expect { subject }.to raise_error(ArgumentError) }
      end
    end

    context 'when encryption_key has invalid length' do
      let(:params) { valid_params.tap { |p| p[:encryption_key] = '123' } }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end
end
