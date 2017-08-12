require 'spec_helper'

describe PgExport::Configuration do
  subject { PgExport::Configuration.new(**params) }
  let(:valid_params) do
    {
      database: 'test',
      keep_dumps: 10,
      dump_encryption_key: '1234567890abcdef',
      ftp_host: 'host',
      ftp_user: 'user',
      ftp_password: 'password'
    }
  end

  describe '.initialize' do
    context 'when all config parameters are provided' do
      let(:params) { valid_params }
      it { expect { subject }.not_to raise_error }
    end

    %i(database keep_dumps dump_encryption_key ftp_host ftp_user ftp_password).each do |param_name|
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

  describe '#ftp_params' do
    let(:params) { valid_params }
    it { expect(subject.ftp_params).to eq(host: 'host', user: 'user', password: 'password') }
  end
end
