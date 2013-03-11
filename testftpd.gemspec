# encoding: utf-8

require './lib/testftpd/version'

Gem::Specification.new do |s|
  s.name        = 'testftpd'
  s.version     = TestFtpd::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Christian Schulze']
  s.email       = ['christian.schulze@gmail.com']
  s.homepage    = 'https://github.com/christian-schulze/testftpd'
  s.summary     = %q{Simple FTP server written in pure Ruby}
  s.description = %q{Simple FTP server written in pure Ruby, allowing integration testing of FTP client code without mocks and stubs}

  s.required_rubygems_version = '~> 1.8.25'
  s.required_ruby_version =     '~> 1.9.2'

  s.rubyforge_project = 'testftpd'

  s.add_development_dependency 'rake',            '~> 10.0.3'
  s.add_development_dependency 'rspec',           '~> 2.12'
  s.add_development_dependency 'simplecov',       '~> 0.7.1'
  s.add_development_dependency 'simplecov-rcov',  '~> 0.2.3'

  s.files         = Dir.glob('{lib}/**/*')
  s.test_files    = Dir.glob('{spec}/**/*')
  s.require_path  = 'lib'
end
