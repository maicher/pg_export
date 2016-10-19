require 'spec_helper'
require 'pg'

describe PgExport::RemoveOldDumps do
  let(:database) { 'database' }
  let(:dir) { 'spec/tmp/dumps' }
  let(:dump) { PgExport::Dump.new(database, dir) }
  let(:total_files_count) { 10 }
  let(:files_to_be_left_count) { 2 }
  subject { PgExport::RemoveOldDumps.new(dump, files_to_be_left_count) }

  before(:each) do
    FileUtils.rm_rf "#{dump.dirname}/*"
    total_files_count.times do
      File.open("#{dump.dirname}/#{database}_#{rand.to_s[2..9]}_#{rand.to_s[2..8]}", 'w') do |f|
        f.write('test')
      end
    end
  end

  after(:each) do
    FileUtils.rm_rf "#{dump.dirname}/*"
  end

  describe '#call' do
    it 'should remove files leaving specified number of files' do
      expect { subject.call }.to change { Dir.entries(dump.dirname).select { |f| !File.directory?(f) }.count }.from(total_files_count).to(files_to_be_left_count)
    end
  end
end
