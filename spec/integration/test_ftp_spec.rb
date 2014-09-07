require 'spec_helper'

require 'net/ftp'
require 'tmpdir'

require 'testftpd'

describe TestFtpd do
  def copy_ftproot(target_path)
    FileUtils.cp_r(File.join(APP_PATH, 'spec/fixtures/ftproot/.'), target_path)
  end

  let(:ftp_port) { 21212 }
  let(:ftp_root) { Dir.mktmpdir('test_ftp_root') }

  subject { TestFtpd::Server.new(port: ftp_port, root_dir: ftp_root) }

  before do
    subject.start
  end

  after do
    subject.shutdown
    FileUtils.rm_rf(ftp_root)
  end

  context 'before authenticating' do
    before :each do
      copy_ftproot(ftp_root)
      @ftp = Net::FTP.new
      @ftp.connect('127.0.0.1', ftp_port)
    end

    after :each do
      @ftp.close
    end

    it 'sends unauthorised message' do
      expect { @ftp.list }.to raise_error(Net::FTPPermError, /Not logged in/)
    end
  end

  context 'after authenticating' do
    before :each do
      copy_ftproot(ftp_root)
      @ftp = Net::FTP.new
      @ftp.connect('127.0.0.1', ftp_port)
      @ftp.login('username', 'password')
    end

    after :each do
      @ftp.close
    end

    context 'when listing files' do
      it 'can list remote files' do
        files = @ftp.list
        files.count.should eq(5)
        files.any? { |file| file =~ /^.*test_file$/ }.should be_true
        files.any? { |file| file =~ /^d.*subfolder$/ }.should be_true
        files.any? { |file| file =~ /^d.*subfolder_to_delete$/ }.should be_true
        files.any? { |file| file =~ /^-.*test_file_to_delete$/ }.should be_true
        files.any? { |file| file =~ /^-.*test_file_to_rename$/ }.should be_true
      end

      it 'can list a specific file' do
        files = @ftp.list('test_file')
        files.count.should eq(1)
        files[0].should =~ /-.*test_file$/
      end

      it 'can list a specific file in a subfolder' do
        files = @ftp.list('subfolder/test_file1')
        files.count.should eq(1)
        files[0].should =~ /-.*test_file1/
      end

      it 'can list a sub folder' do
        files = @ftp.list('subfolder')
        files.count.should eq(3)
        files.any? { |file| file =~ /test_file1/ }.should be_true
      end
    end

    it 'can query the current remote directory' do
      @ftp.pwd.should eq('/')
    end

    context 'when nlst files' do
      it 'can nlst remote files' do
        files = @ftp.nlst
        files.count.should eq(5)
        files.any? { |file| file =~ /^test_file$/ }.should be_true
        files.any? { |file| file =~ /^subfolder$/ }.should be_true
        files.any? { |file| file =~ /^subfolder_to_delete$/ }.should be_true
        files.any? { |file| file =~ /^test_file_to_delete$/ }.should be_true
        files.any? { |file| file =~ /^test_file_to_rename$/ }.should be_true
      end

      it 'can nlst a specific file' do
        files = @ftp.nlst('test_file')
        files.count.should eq(1)
        files[0].should =~ /^test_file$/
      end

      it 'can nlst a specific file in a subfolder' do
        files = @ftp.nlst('subfolder/test_file1')
        files.count.should eq(1)
        files[0].should =~ /^test_file1$/
      end

      it 'can nlst a sub folder' do
        files = @ftp.nlst('subfolder')
        files.count.should eq(3)
        files.any? { |file| file =~ /^test_file1$/ }.should be_true
        files.any? { |file| file =~ /^test_file2$/ }.should be_true
        files.any? { |file| file =~ /^subfolder$/ }.should be_true
      end
    end

    it 'can query modified time of remote file' do
      modified_time = File.mtime(File.join(ftp_root, 'test_file')).strftime('%Y%m%d%H%M%S')
      @ftp.mdtm('test_file').should eql(modified_time)
    end

    it 'can query size of remote file' do
      size = File.size(File.join(ftp_root, 'test_file'))
      @ftp.size('test_file').should eq(size)
    end

    context 'when downloading a file' do
      it 'can use binary mode' do
        filename = 'test_file'
        local_filepath = File.join(Dir.tmpdir, filename)
        @ftp.binary = true
        @ftp.get('test_file', local_filepath)
        File.exists?(local_filepath).should be_true
      end

      it 'can use text mode' do
        filename = 'test_file'
        local_filepath = File.join(Dir.tmpdir, filename)
        @ftp.binary = false
        @ftp.get('test_file', local_filepath)
        File.exists?(local_filepath).should be_true
      end

      it 'can use passive mode' do
        filename = 'test_file'
        local_filepath = File.join(Dir.tmpdir, filename)
        @ftp.passive = true
        @ftp.get('test_file', local_filepath)
        File.exists?(local_filepath).should be_true
      end
    end

    context 'when changing folders' do
      it 'can change into sub folders' do
        @ftp.chdir('subfolder')
        @ftp.pwd.should eq(File.join(ftp_root, 'subfolder'))
      end

      it 'can change into parent folder' do
        @ftp.chdir('subfolder')
        @ftp.chdir('..')
        @ftp.pwd.should eq(ftp_root)
      end

      it 'does not allow folders outside the ftp root folder' do
        @ftp.chdir('..')
        @ftp.pwd.should eq('/')
      end
    end

    it 'can create a remote folder' do
      @ftp.mkdir('new_subfolder')
      Dir.exists?(File.join(ftp_root, 'new_subfolder')).should be_true
    end

    it 'can upload a file' do
      filename = 'test_file_to_upload'
      local_filepath = File.join(APP_PATH, 'spec/fixtures', filename)
      @ftp.put(local_filepath, filename)
      File.exists?(File.join(ftp_root, filename)).should be_true
    end

    it 'can delete a remote file' do
      @ftp.delete('test_file_to_delete')
      File.exists?(File.join(ftp_root, 'test_file_to_delete')).should be_false
    end

    it 'can rename a remote file' do
      @ftp.rename('test_file_to_rename', 'test_file_renamed')
      File.exists?(File.join(ftp_root, 'test_file_renamed')).should be_true
    end

    it 'can delete a remote folder' do
      @ftp.rmdir('subfolder_to_delete')
      File.exists?(File.join(ftp_root, 'subfolder_to_delete')).should be_false
    end

    it 'responds correctly to unrecognized commands' do
      expect { @ftp.sendcmd('asdf') }.to raise_error(Net::FTPPermError, /command unrecognized/)
    end
  end

end
