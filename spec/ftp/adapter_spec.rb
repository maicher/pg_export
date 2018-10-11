# frozen_string_literal: true

require 'pg_export/ftp/adapter'
require 'ftp_mock'

RSpec.describe PgExport::Ftp::Adapter do
  let(:params) { { host: 'ftp.example.com', user: 'user', password: 'password' } }
  let(:mock) { FtpMock.new }

  before(:each) { allow(Net::FTP).to receive(:new).with(*params.values).and_return(mock) }

  subject { PgExport::Ftp::Adapter.new(connection: mock) }

  it { expect(subject).to respond_to(:list) }
  it { expect(subject).to respond_to(:delete) }
  it { expect(subject).to respond_to(:persist) }
  it { expect(subject).to respond_to(:get) }
  it { expect(subject).to respond_to(:ftp) }
  it { expect(subject).to respond_to(:to_s) }
end
