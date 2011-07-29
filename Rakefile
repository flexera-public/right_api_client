$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'lib/right_api_client/client'

task :build do
  system "gem build right_api_client.gemspec"
end

task :release => :build do
  system "gem push right_api_client-#{RightApi::Client::VERSION}"
end