require File.expand_path('../lib/right_api_client', __FILE__)
require 'rake'
require 'rspec/core/rake_task'

task :build do
  system "gem build right_api_client.gemspec"
end

task :release => :build do
  system "gem push right_api_client-#{RightApi::Client::VERSION}.gem"
end

RSpec::Core::RakeTask.new do |t|
  t.pattern = Dir['**/*_spec.rb']
end

