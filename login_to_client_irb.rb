# A quick way to login to the API and jump into IRB so you can experiment with the client.
# Add this to your bash profile to make it simpler:
#   alias client='bundle exec ruby login_to_client_irb.rb'

require File.expand_path('../lib/right_api_client', __FILE__)
require 'yaml'
require 'irb'

begin
  @client = RightApi::Client.new(YAML.load_file(File.expand_path('../examples/login.yml', __FILE__)))
  puts "logged-in to the API, use the '@client' variable to use the client, e.g. '@client.session.index.message' will output:"
  puts @client.session.index.message
end

IRB.start
