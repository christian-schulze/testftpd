# TestFtpd

Simple FTP server written in pure Ruby.

My primary use case is integration testing FTP client code in a Rails 3.1 codebase using RSpec 2.

## Usage

Update your Gemfile

```ruby
group :test do
  gem 'test_ftpd', git: 'git@github.com:christian-schulze/testftpd.git', require: false
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

## Ackowledgements

This code builds upon Rubtsov Vitaly' excellent project [dyn-ftp-serv](http://rubyforge.org/projects/dyn-ftp-serv/) created in late 2007.

## Contributers

* Christian Schulze

## License

Released under the MIT license. Please see the `LICENSE` file for more information.
