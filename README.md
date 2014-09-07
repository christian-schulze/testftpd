# TestFtpd

[![Gem Version](https://badge.fury.io/rb/testftpd.png)](http://badge.fury.io/rb/testftpd) [![Build Status](https://travis-ci.org/christian-schulze/testftpd.png)](https://travis-ci.org/christian-schulze/testftpd)

Simple FTP server written in pure Ruby.

The primary use case is for integration testing FTP client code in a Rails 3.1 codebase using RSpec 2. 

Enough FTP commands are implemented to be useful, including:


<table>
  <tr>
    <td>port</td><td>pasv</td><td>user</td><td>pass</td><td>quit</td><td>syst</td><td>type</td>
  </tr><tr>
    <td>list</td><td>retr</td><td>stor</td><td>dele</td><td>size</td><td>mdtm</td><td>rnfr/rnto</td>
  </tr><tr>
    <td>pwd</td><td>cdup</td><td>cwd</td><td>mkd</td><td>rmd</td><td>nlst</td><td></td>
  </tr>
</table>

## Usage

Update your Gemfile

```ruby
group :test do
  gem 'testftpd', :require => false
end
```

Write some specs...

```ruby
require 'spec_helper'
require 'testftpd'

describe 'Test all the things!' do
  let(:ftp_port) { 21212 }
  let(:ftp_root) { Rails.root.to_s }

  before do
    @ftp_server = TestFtpd::Server.new(port: ftp_port, root_dir: ftp_root)
    @ftp_server.start
  end

  after do
    @ftp_server.shutdown
  end

  it 'lists remote files' do
    ftp = Net::FTP.new
    ftp.connect('127.0.0.1', ftp_port)
    ftp.login('username', 'password')
    ftp.list.any? { |file| file ~= /Gemfile/ }.should be_true
  end
end
```

You can change the list command format by monkey-patching or stubbing. Heres a stubbing technique I've used:

```ruby
require 'spec_helper'
require 'testftpd'

describe 'Test all the things!' do
  let(:ftp_port) { 21212 }
  let(:ftp_root) { Rails.root.to_s }

  before do
    @ftp_server = TestFtpd::Server.new(port: ftp_port, root_dir: ftp_root)
    @ftp_server.start
  end

  after do
    @ftp_server.shutdown
  end

  before :each do
    TestFtpd::FileSystemProvider.stub(:format_list_entry) do |entry|
      raw =  entry.ftp_date.strftime('%m-%d-%g  %I:%M%p') + ' '
      if entry.directory?
        raw += '    <DIR>            '
      else
        raw += entry.ftp_size.to_s.rjust(20, ' ') + ' '
      end
      raw += entry.ftp_name
      raw += "\r\n"
      raw
    end
  end

  it 'lists remote files' do
    ftp = Net::FTP.new
    ftp.connect('127.0.0.1', ftp_port)
    ftp.login('username', 'password')
    ftp.list.any? { |file| file ~= /Gemfile/ }.should be_true
  end
```

This will most likely make it into the *TestFtpd* code base as a configurable option, stay tuned.

## Todo

* more tests
* add simple authentication provider
* implement more FTP commands

## Acknowledgements

This code builds upon Rubtsov Vitaly' excellent project [dyn-ftp-serv](http://rubyforge.org/projects/dyn-ftp-serv/) created in late 2007.

Also [Francis Hwang](https://github.com/fhwang/fake_ftp) who originally adapted *dyn-ftp-serv*, and gave me a head start for this project.

## Contributers

* Christian Schulze

## License

Released under the MIT license. Please see the `LICENSE` file for more information.
