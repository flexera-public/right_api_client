# A quick way to login to the API and jump into IRB so you can experiment with the client.
# Add this to your bash profile to make it simpler:
#   alias client='bundle exec ruby login_to_client_irb.rb'

require './lib/right_api_client'
require 'yaml'
require 'irb'

@client = RightApiClient.new(YAML.load_file(File.dirname(__FILE__) + '/examples/login.yml'))
puts "logged-in to the API, use the '@client' variable to use the client, e.g. '@client.session.message' will output:"
puts @client.session.message
begin
  @local_client = RightApiClient.new(YAML.load_file(File.dirname(__FILE__) + '/examples/local_login.yml'))
  puts '@local_client is also available - this will run against the local API server'
rescue
  puts '@local_client is not available, API is probably not running locally.'
end
IRB.start
