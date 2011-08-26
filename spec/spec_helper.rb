require File.expand_path('../../lib/right_api_client', __FILE__)
require 'spec'
require 'rest_client'

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

module MockSpecHelper
  def given_user_facing_client
    @api_version = RightApi::Client::API_VERSION
    @rest_client = RestClient::Resource.new(RightApi::Client::DEFAULT_API_URL)
    flexmock(RestClient::Resource).should_receive(:new).and_return(@rest_client)

    session = flexmock(:cookies => '')
    header = {'X_API_VERSION' => @api_version, :cookies => '', :accept => :json}
    flexmock(@rest_client).should_receive(:post).with(
        {'email' => 'email', 'password' => 'password', 'account_href' => '/api/accounts/1'},
        {'X_API_VERSION' => @api_version}, Proc).and_return(session)
    flexmock(@rest_client).should_receive(:get).with(header, Proc).and_return(['','{}'])
    @client = RightApi::Client.new(:email => 'email', :password => 'password', :account_id => '1')
  end

  def given_instance_facing_client

  end
end