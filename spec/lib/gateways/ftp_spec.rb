# frozen_string_literal: true

require 'pg_export/lib/pg_export/gateways/ftp'
require 'ftp_mock'

RSpec.describe PgExport::Gateways::Ftp do
  let(:params) { { host: 'ftp.example.com', user: 'user', password: 'password' } }
  let(:mock) { FtpMock.new }

  before(:each) do
    allow(Net::FTP).to receive(:new).with(*params.values).and_return(mock)
    allow(mock).to receive(:passive=).with(true)
  end

  subject { described_class.new(**params) }

  it { expect(subject).to respond_to(:list) }
  it { expect(subject).to respond_to(:delete) }
  it { expect(subject).to respond_to(:persist) }
  it { expect(subject).to respond_to(:get) }
  it { expect(subject).to respond_to(:to_s) }
end
