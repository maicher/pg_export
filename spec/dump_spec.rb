require 'spec_helper'

describe PgExport::Dump do
  let(:database) { 'pg_backup_database' }
  let(:dir) { 'spec/tmp/dumps' }
  subject { PgExport::Dump.new(database, dir) }

  it { expect(subject).to respond_to(:database) }
  it { expect(subject).to respond_to(:dirname) }
  it { expect(subject).to respond_to(:basename) }
  it { expect(subject).to respond_to(:basename_gz) }
  it { expect(subject).to respond_to(:pathname) }
  it { expect(subject).to respond_to(:pathname_gz) }
  it { expect(subject).to respond_to(:size) }
  it { expect(subject).to respond_to(:size_gz) }

  describe '#basename' do
    it 'should initialize object with name generated from database and timestamp' do
      expect(subject.basename.to_s).to match(/#{database}_[0-9]{8}_[0-9]{6}/)
    end
  end

  describe '#regexp' do
    it { expect(subject.regexp).to eq(/#{database}_[0-9]{8}_[0-9]{6}/) }
  end

  describe '#ftp_regexp' do
    it { expect(subject.ftp_regexp).to eq("#{database}_*") }
  end

  describe '#initialize' do
    let!(:dirname) { PgExport::Dump.new(database, dir).dirname }
    before(:each) do
      FileUtils.rm_rf dirname
    end

    it 'should create dir if not exist' do
      expect { subject }.to change { File.directory?(dirname) }.from(false).to(true)
    end
  end
end
