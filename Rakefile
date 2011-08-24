$:.unshift('lib')
require 'right_api_client'
require 'rake'
require 'spec/rake/spectask'

task :build do
  system "gem build right_api_client.gemspec"
end

task :release => :build do
  system "gem push right_api_client-#{RightApi::Client::VERSION}"
end

Spec::Rake::SpecTask.new('user_facing_specs') do |t|
  t.spec_files = Dir.glob('spec/user_facing/*_spec.rb')
  t.spec_opts << '--format nested'
  t.spec_opts << '--colour'
end

Spec::Rake::SpecTask.new('instance_facing_specs') do |t|
  t.spec_files = Dir.glob('spec/instance_facing/*_spec.rb')
  t.spec_opts << '--format nested'
  t.spec_opts << '--colour'
end

Spec::Rake::SpecTask.new('generic_specs') do |t|
  t.spec_files = Dir.glob('spec/generic/*_spec.rb')
  t.spec_opts << '--format nested'
  t.spec_opts << '--colour'
end