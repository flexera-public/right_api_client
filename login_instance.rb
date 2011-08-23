# A quick way to login to the API and jump into IRB so you can experiment with the client.
# Add this to your bash profile to make it simpler:
#   alias client='bundle exec ruby login_to_client_irb.rb'
#

require 'rubygems'
require 'rest_client'
require 'irb'
require '/var/spool/cloud/user-data'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
require 'client'
require 'instance_facing'

account_id, token = ENV['RS_API_TOKEN'].split(/:/)
api_url = ENV['RS_SERVER']
puts account_id, token, api_url

@client = RightApi::InstanceFacing.new( :instance_token => token,
                                        :account_id => account_id,
                                        :api_url => "https://#{api_url}" )

IRB.start
