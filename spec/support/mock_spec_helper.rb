
module MockSpecHelper

  def mock_rest_client
    @api_version = RightApi::Client::API_VERSION
    @rest_client = RestClient::Resource.new(RightApi::Client::DEFAULT_API_URL)
    flexmock(RestClient::Resource).should_receive(:new).and_return(@rest_client)
    @session = flexmock(:cookies => '')
    @header = {'X_API_VERSION' => @api_version, :cookies => '', :accept => :json}
  end

  def given_user_facing_client
    mock_rest_client
    flexmock(@rest_client).should_receive(:post).with(
        {'email' => 'email', 'password' => 'password', 'account_href' => '/api/accounts/1'},
        {'X_API_VERSION' => @api_version}, Proc).and_return(@session)
    flexmock(@rest_client).should_receive(:get).with(@header, Proc).and_return(['', '{}'])
    @client = RightApi::Client.new(:email => 'email', :password => 'password', :account_id => '1')
  end

  def given_instance_facing_client
    mock_rest_client
    flexmock(@rest_client).should_receive(:post).with(
        {'instance_token' => 'instance_token', 'account_href' => '/api/accounts/1'},
        {'X_API_VERSION' => @api_version}, Proc).and_return(@session)
    flexmock(@rest_client).should_receive(:get).with(@header, Proc).and_return(['', '{"links": [
        {
          "href": "/api/clouds/1/instances/1",
          "rel": "self"
        }]}'])
    @client = RightApi::Client.new(:instance_token => 'instance_token', :account_id => '1')
  end
end

$config.include MockSpecHelper

