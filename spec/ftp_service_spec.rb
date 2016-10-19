require 'spec_helper'

RSpec.describe PgExport::FtpService do
  let(:params) { { host: 'ftp.example.com', user: 'user', password: 'password' } }
  let(:mock) { FtpMock.new }

  before(:each) { allow(Net::FTP).to receive(:new).with(*params.values).and_return(mock) }

  subject { PgExport::FtpService.new(params) }

  it { expect(subject).to respond_to(:list) }
  it { expect(subject).to respond_to(:delete) }
  it { expect(subject).to respond_to(:upload_file) }
end
