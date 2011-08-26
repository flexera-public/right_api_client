# This file provides a long list of examples that demonstrate how the
# Right API Client can be used. Un-comment the section you want to try...

require 'yaml' # only needed if you want to put your creds in .yml file
require File.expand_path('../../lib/right_api_client', __FILE__)

# Read username, password and account_id from file, or you can just pass them
# as arguments when creating a new client.
args = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/login.yml'))

puts "Creating RightScale API Client and logging in..."
# Account ID is available from the browser address bar on this page: dashboard > Settings > Account Settings
client = RightApi::Client.new(:email =>args[:email], :password => args[:password], :account_id => args[:account_id])
puts client.session.index.message
puts 'Available methods:', client.api_methods
##Can also specify api_url and api_version, which is useful for testing, e.g.:
#client = RightApiClient.new(:email => args[:email], :password => args[:password], :account_id => args[:account_id],
#                            :api_url => 'https://test.rightscale.com', :api_version => '2.0')
##Or you can just tell the client to use an already-authenticated cookie (from another client or session), e.g.:
#client = RightApiClient.new(:cookies => my_already_authenticated_cookies)

# The HTTP calls made by right_api_client can be logged in two ways:
# Log to a file
#client.log('~/right_api_client.log')
# Log to SDTOUT, which is usually the screen
#require 'logger'
#client.log(STDOUT)

#More examples to come...