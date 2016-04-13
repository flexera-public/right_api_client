# A quick way to login to the API and jump into IRB so you can experiment with the client.
# Add this to your bash profile to make it simpler:
#   alias client='bin/console'

require File.expand_path('../lib/right_api_client', __FILE__)
require 'yaml'
require 'irb'

begin
  @client = RightApi::Client.new(YAML.load_file(File.expand_path('../config/login.yml', __FILE__)))
  puts "logged-in to the API, use the '@client' variable to use the client"
end

IRB.start
