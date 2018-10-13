# frozen_string_literal: true

require 'pg_export/value_objects/configuration'

describe PgExport::ValueObjects::Configuration do
  subject { PgExport::ValueObjects::Configuration.new(**params) }
  let(:valid_params) do
    {
      dump_encryption_key: '1234567890abcdef',
      ftp_host: 'host',
      ftp_user: 'user',
      ftp_password: 'password',
      logger_format: :plain
    }
  end

  describe '.initialize' do
    context 'when all config parameters are provided' do
      let(:params) { valid_params }
      it { expect { subject }.not_to raise_error }
    end

    %i[dump_encryption_key ftp_host ftp_user ftp_password logger_format].each do |param_name|
      context "when #{param_name} parameter are missing" do
        let(:params) { valid_params.tap { |p| p.delete(param_name) } }
        it { expect { subject }.to raise_error(Dry::Struct::Error) }
      end
    end

    context 'when dump_encryption_key has invalid length' do
      let(:params) { valid_params.tap { |p| p[:dump_encryption_key] = '123' } }
      it { expect { subject }.to raise_error(Dry::Struct::Error) }
    end
  end
end
