$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'lib/version'
require 'rake'
require 'spec/rake/spectask'

task :build do
  system "gem build right_api_client.gemspec"
end

task :release => :build do
  system "gem push right_api_client-#{RightApi::Client::VERSION}"
end

Spec::Rake::SpecTask.new('detail_specs') do |t|
  t.spec_files = Dir.glob('spec/detail_specs/*_spec.rb')
  t.spec_opts << '--format nested'
  t.spec_opts << '--colour'
end

Spec::Rake::SpecTask.new('detail_instance_specs') do |t|
  t.spec_files = Dir.glob('spec/detail_instance_specs/*_spec.rb')
  t.spec_opts << '--format nested'
  t.spec_opts << '--colour'
end

Spec::Rake::SpecTask.new('generic_specs') do |t|
  t.spec_files = Dir.glob('spec/generic_specs/*_spec.rb')
  t.spec_opts << '--format nested'
  t.spec_opts << '--colour'
end