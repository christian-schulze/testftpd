# TestFtpd

Simple FTP server written in pure Ruby.

The primary use case is for integration testing FTP client code in a Rails 3.1 codebase using RSpec 2. 

Enough FTP commands are implemented to be useful, including:
* cdup
* cwd
* dele
* list
* mdtm
* mkd
* pass
* pasv
* port
* pwd
* rmd
* quit
* retr
* size
* stor
* rnfr/rnto
* syst - currently hard coded to 'UNIX'
* type - does nothing
* user

## Usage

Update your Gemfile

```ruby
group :test do
  gem 'testftpd', :git => 'git://github.com/christian-schulze/testftpd.git', :require => false
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
