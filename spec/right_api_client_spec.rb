# To Run:
# Make sure you have a valid examples/login.yml (see login.yml.example for details)
# > cd spec
# > bundle exec spec right_api_client_spec.rb

require File.join(File.dirname(__FILE__), 'spec_helper')

# These tests cover the basic operations of the client, and can certainly
# be extended in the future to improve test coverage.
describe RightApi::Client do
  before(:all) do
    @client = example_client
  end

  it "should login" do
    @client.headers[:cookies].should_not be_nil
  end

  it "should have root and base resources" do
    @client.api_methods.should include(:session)
    @client.api_methods.should_not be_empty
  end

  it "should return a Resources class for collection of resources" do
    @client.clouds.should be_kind_of(RightApi::Resources)
  end

  it "should return arrays for collection of resources" do
    @client.clouds.index.should be_kind_of(Array)
  end

  it "should return single object for a resource with specific id" do
    @client.clouds.index.first.should be_kind_of(RightApi::ResourceDetail)
  end

  it "should have attributes for a resource" do
    @client.clouds.index.first.show.attributes.should_not be_empty
  end

  it "should have associations for a resource" do
    @client.clouds.index.first.show.associations.should_not be_empty
  end

  it "should have actions for a resource" do
    actions = @client.servers.index.first.show.actions.to_a
    (actions.include?(:launch) || actions.include?(:terminate)).should == true
  end

  it "should have create, update and destroy methods for resources" do
    ['deployments', 'server_arrays', 'servers'].each do |res|
      resource = @client.send(res)
      resource.api_methods.should include(:create)
      resource.index[0].api_methods.should include(:destroy)
      resource.index[0].api_methods.should include(:update)
    end
  end

  describe "#initialize" do

    it "creates a logged in client" do

      client = RightApi::Client.new(example_args)

      client.headers[:cookies].should_not == nil
    end

    it "accepts a cookie argument" do

      client1 = RightApi::Client.new(
        example_args.merge('cookies' => @client.cookies))
      client2 = RightApi::Client.new(
        example_args)

      client1.cookies.should == @client.cookies
      client2.cookies.should_not == @client.cookies
    end
  end


  describe "#cookies" do

    it "returns a Hash with a 'domain' and a '_session_id'" do

      @client.cookies.class.should == Hash
      @client.cookies.keys.sort.should == %w[ _session_id domain rs_gbl ]
    end
  end

  describe "#tags" do
    it "should return a Resources object" do
      @client.tags.should be_kind_of(RightApi::Resources)
    end
    it "should have methods" do
      @client.tags.api_methods.should_not be_empty
      @client.tags.api_methods.should include(:by_tag)
      @client.tags.api_methods.should include(:by_resource)
      @client.tags.api_methods.should include(:multi_add)
      @client.tags.api_methods.should include(:multi_delete)
    end
  end

  describe "#backups" do
    it "should return a dummy resource object" do
      @client.backups.should be_kind_of(RightApi::Resources)
    end
    it "should have methods" do
      @client.backups.api_methods.should_not be_empty
      @client.backups.api_methods.should include(:index)
      @client.backups.api_methods.should include(:create)
      @client.backups.api_methods.should include(:cleanup)
    end
  end
end
