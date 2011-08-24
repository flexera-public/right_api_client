require File.expand_path('../../spec_helper', __FILE__)

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
    @client.api_methods.should include(:volumes)
    @client.api_methods.should include(:volume_attachments)
    @client.api_methods.should include(:volume_snapshots)
    @client.api_methods.should include(:volume_types)
    @client.api_methods.should include(:live_tasks)
    @client.api_methods.should include(:backups)
    @client.api_methods.should_not be_empty
  end
  
  it "should be a resource object" do
    @client.get_instance.should be_kind_of(RightApi::ResourceDetail)
  end
  
  
  describe "#volumes" do
    it "should return a resources object" do
      @client.volumes.should be_kind_of(RightApi::Resources)
    end
    it "should have methods" do
      @client.volumes.api_methods.should_not be_empty
      @client.volumes.api_methods.should include(:index)
      @client.volumes.api_methods.should include(:create)
    end
  end
  describe "#volume_snapshots" do
    it "should return a resources object" do
      @client.volume_snapshots.should be_kind_of(RightApi::Resources)
    end
    it "should have methods" do
      @client.volume_snapshots.api_methods.should_not be_empty
      @client.volume_snapshots.api_methods.should include(:index)
      @client.volume_snapshots.api_methods.should include(:create)
    end
  end
  describe "#volume_attachments" do
    it "should return a resources object" do
      @client.volume_attachments.should be_kind_of(RightApi::Resources)
    end
    it "should have methods" do
      @client.volume_attachments.api_methods.should_not be_empty
      @client.volume_attachments.api_methods.should include(:index)
      @client.volume_attachments.api_methods.should include(:create)
    end
  end
  describe "#volume_types" do
    it "should return a resources object" do
      @client.volume_types.should be_kind_of(RightApi::Resources)
    end
    it "should have methods" do
      @client.volume_types.api_methods.should_not be_empty
      @client.volume_types.api_methods.should include(:index)
    end
  end
  
  describe "#backups" do
    it "should return a resources object" do
      @client.backups.should be_kind_of(RightApi::Resources)
    end
    it "should have methods" do
      @client.backups.api_methods.should_not be_empty
      @client.backups.api_methods.should include(:create)
      @client.backups.api_methods.should include(:cleanup)
    end
  end
end
