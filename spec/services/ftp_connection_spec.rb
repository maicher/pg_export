require 'spec_helper'

RSpec.describe PgExport::FtpConnection do
  let(:params) { { host: 'ftp.example.com', user: 'user', password: 'password' } }
  let(:mock) { FtpMock.new }

  let(:subject) { PgExport::FtpConnection.new(params) }

  before(:each) do
    allow(Net::FTP).to receive(:new).with(params[:host], params[:user], params[:password]).and_return(mock)
    allow(mock).to receive(:passive=).with(true).exactly(1).times
  end

  describe '#open' do
    it { subject }
  end

  describe '#close' do
    before(:each) do
      allow(mock).to receive(:close).exactly(1).times
    end
    it { subject }
  end

  describe '#ftp' do
    it { expect(subject.ftp).to eq(mock) }
  end
end
