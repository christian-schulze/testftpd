#!/usr/bin/env rake

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  #t.fail_on_error = false
end

desc 'Run complete test suite'
task :test do
  Rake::Task['spec'].invoke
end

desc 'Run complete test suite and calculate coverage'
task :test_cov do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].invoke
end

task :default => :test
