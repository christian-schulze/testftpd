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
  let(:port) { 21212 }
  subject { TestFtpd::Server.new(port: port, root_dir: Rails.root.to_s) }

  before do
    subject.start
  end

  after do
    subject.shutdown
  end

  it 'lists remote files' do
    ftp = Net::FTP.new
    ftp.connect('127.0.0.1', port)
    ftp.login('username', 'password')
    ftp.list.any? { |file| file ~= /Gemfile/ }.should be_true
  end
end
```

## Ackowledgements

This code builds upon Rubtsov Vitaly' excellent project [dyn-ftp-serv](http://rubyforge.org/projects/dyn-ftp-serv/) created in late 2007.

## Contributers

* Christian Schulze
