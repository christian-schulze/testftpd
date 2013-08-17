require 'spec_helper'

require 'testftpd'

describe TestFtpd::Server do

  let(:ftp_port) { 21212 }
  let(:ftp_root) { APP_PATH }

  subject { TestFtpd::Server.new(port: ftp_port, root_dir: ftp_root) }

  after :each do
    subject.shutdown
  end

  describe '.start(timeout = 2)' do
    it 'raises exception if ftp process does not start within timeout' do
      Thread.stub(:new) { sleep 0.5 }
      expect { subject.start(0.1) }.to raise_error(TimeoutError)
    end
  end

  describe '.start(timeout = 2)' do
    it 'raises exception if ftp process does not shutdown within timeout' do
      subject.start

      original_method = subject.method(:running?)
      subject.stub(:running?) do |*args, &block|
        sleep 0.1
        original_method.call
      end

      expect { subject.shutdown(0.01) }.to raise_error(TimeoutError)
    end
  end

end
