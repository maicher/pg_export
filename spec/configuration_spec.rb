require 'spec_helper'

describe PgExport::Configuration do
  let(:configuration) do
    c = PgExport::Configuration.new
    c.database = 'test',
    c.keep_dumps = 10,
    c.ftp_host = 'host'
    c.ftp_user = 'user'
    c.ftp_password = 'password'
    c
  end

  describe '#validate' do
    subject { configuration }
    context 'when all config parameters are provided' do
      it { expect { subject.validate }.not_to raise_error }
    end

    PgExport::Configuration::DEFAULTS.keys.each do |p|
      context "when field #{p} is missing" do
        before(:each) { configuration.send("#{p}=", nil) }
        subject { configuration }
        it { expect { subject.validate }.to raise_error(PgExport::InvalidConfigurationError) }
      end
    end
  end

  describe '#ftp_params' do
    subject { configuration }
    it { expect(subject.ftp_params).to eq(host: 'host', user: 'user', password: 'password') }
  end
end
