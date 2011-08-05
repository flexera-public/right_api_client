# A quick way to login to the API and jump into IRB so you can experiment with the client.
# Add this to your bash profile to make it simpler:
#   alias client='bundle exec ruby login_to_client_irb.rb'

require 'rubygems'
require 'rest_client'
require './lib/right_api_client/client'
require 'yaml'
require 'irb'

@client = RightApi::Client.new(YAML.load_file(File.dirname(__FILE__) + '/examples/instance_login.yml'))

IRB.start
