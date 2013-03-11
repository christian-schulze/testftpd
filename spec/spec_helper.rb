require 'rubygems'
require 'bundler/setup'
require 'rspec'

APP_PATH = File.expand_path(File.join(File.dirname(__FILE__),'..'))

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.root(APP_PATH)
end

RSpec.configure do |config|
  config.before(:suite) do

  end

  config.before(:each) do

  end
end
