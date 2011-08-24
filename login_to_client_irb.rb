# A quick way to login to the API and jump into IRB so you can experiment with the client.
# Add this to your bash profile to make it simpler:
#   alias client='bundle exec ruby login_to_client_irb.rb'

$:.unshift('lib')
require 'right_api_client'
require 'yaml'
require 'irb'

begin
  @client = RightApi::Client.new(YAML.load_file(File.dirname(__FILE__) + '/examples/login.yml'))
  puts "logged-in to the API, use the '@client' variable to use the client, e.g. '@client.session.index.message' will output:"
  puts @client.session.index.message
end

IRB.start
