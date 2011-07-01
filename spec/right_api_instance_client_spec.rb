# This test verifies that the instance facing calls work
# To Run:
# Make sure you have a valid examples/instance_login.yml (see login.yml.example for details)
# > cd spec
# > bundle exec spec right_api_instance_client_spec.rb 


require File.join(File.dirname(__FILE__), 'spec_helper')

# These tests cover the basic operations of the client, and can certainly
# be extended in the future to improve test coverage.
describe "#RightApiInstanceClient" do
  before(:all) do
    @client = example_instance_client
  end

  it "should login" do
    @client.headers[:cookies].should_not be_nil
  end

  it "should have root and base resources" do
    @client.api_methods.should include(:get_instance)
    @client.api_methods.should include(:clouds)
    @client.api_methods.should_not be_empty
  end
  
  it "should be a resource object" do
    @client.get_instance.should be_kind_of(RightApiClient::Resource)
  end
  
  it "should return a dummy resource object" do
    @client.clouds.should be_kind_of(RightApiClient::DummyResource)
  end
  
  it "should have methods" do
    @client.clouds.api_methods.should_not be_empty
    @client.clouds.api_methods.should include(:volumes)
    @client.clouds.api_methods.should include(:volume_types)
    @client.clouds.api_methods.should include(:volume_attachments)
    @client.clouds.api_methods.should include(:volume_snapshots)
  end

end
