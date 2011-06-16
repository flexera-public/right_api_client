require File.join(File.dirname(__FILE__), 'spec_helper')

# These tests cover the basic operations of the client, and can certainly
# be extended in the future to improve test coverage.
describe RightApiClient do
  before(:all) do
    @client = RightApiClient.new(YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../examples/login.yml')))
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
    @client.clouds.first.should be_kind_of(RightApiClient::Resource)
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

  describe "#initialize" do

    it 'creates a logged in client' do

      args = YAML.load_file(
        File.join(File.dirname(__FILE__), '../examples/login.yml'))

      client = RightApiClient.new(args)

      client.headers[:cookies].should_not == nil
    end

    it 'accepts a cookie argument' do

      args = YAML.load_file(
        File.join(File.dirname(__FILE__), '../examples/login.yml'))

      client1 = RightApiClient.new(args.merge('cookies' => @client.cookies))
      client2 = RightApiClient.new(args)

      client1.cookies.should == @client.cookies
      client2.cookies.should_not == @client.cookies
    end
  end

  describe "#resource" do

    it "returns a resource given a path" do

      cloud = @client.resource('/api/clouds/232')

      cloud.class.should == RightApiClient::Resource
      cloud.resource_type.should == 'cloud'
    end
  end

  describe "#cookies" do

    it "returns a Hash with a 'domain' and a '_session_id'" do

      @client.cookies.class.should == Hash
      @client.cookies.keys.sort.should == %w[ _session_id domain rs_gbl ]
    end
  end
end
