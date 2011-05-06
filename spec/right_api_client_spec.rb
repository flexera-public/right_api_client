require File.expand_path(File.dirname(__FILE__) + '/../lib/right_api_client')
require 'yaml'

# These tests cover the basic operations of the client, and can certainly
# be extended in the future to improve test coverage.
describe RightApiClient do
  before(:all) do
    # Read username, password and account_id from file
    args = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../examples/login.yml'))
    @client = RightApiClient.new(:email =>args[:email], :password => args[:password], :account_id => args[:account_id])
  end
  
  it "should login" do
    @client.headers[:cookies].should_not be_nil
  end   
    
  it "should have root and base resources" do
    @client.api_methods.should include(:session)
    @client.api_methods.should_not be_empty
  end

  it "should return arrays for collection of resources" do
    @client.clouds.should be_kind_of(Array)
  end

  it "should return single object for a resource with specific id" do
    @client.clouds.first.should be_kind_of(Resource)
  end

  it "should have attributes for a resource" do
    @client.clouds.first.attributes.should_not be_empty
  end

  it "should have actions for a resource" do
    actions = @client.servers.first.actions.to_a
    (actions.include?(:launch) || actions.include?(:terminate)).should == true
  end

  it "should have create, update and destroy methods for resources" do
    ['deployments', 'server_arrays', 'servers'].each do |resource|
      @client.send(resource).api_methods.should include(:create)
      @client.send(resource)[0].api_methods.should include(:destroy)
      @client.send(resource)[0].api_methods.should include(:update)
    end
  end
  
end