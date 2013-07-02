require 'spec_helper'

require 'testftpd'

describe TestFtpd::ServerBuilder do

  let(:ftp_ports) { (21212..21232).to_a }
  let(:ftp_options) { { root_dir: APP_PATH } }

  subject { TestFtpd::ServerBuilder }

  describe '#build' do
    context 'when a port is in use' do
      before(:each) do
        @dummy_server = TCPServer.new('', ftp_ports.first)
      end
      after(:each) do
        @dummy_server.close
        @server.shutdown
      end

      it 'builds a server on the next available port' do
        @server = subject.build(ftp_options, ftp_ports)
        expect( @server ).to be_an_instance_of TestFtpd::Server
        expect( @server.config[:port] ).to eq ftp_ports[1]
      end
    end
  end

end
