require File.expand_path('../lib/right_api_client', __FILE__)
require 'rake'
require 'spec/rake/spectask'

task :build do
  system "gem build right_api_client.gemspec"
end

task :release => :build do
  system "gem push right_api_client-#{RightApi::Client::VERSION}"
end

Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = Dir.glob('spec/*_spec.rb')
  t.spec_opts << '--format nested'
  t.spec_opts << '--colour'
end