require File.expand_path('../../spec_helper', __FILE__)

describe RightApi::Resources, :unit=>true do
  before(:each) do
    given_user_facing_client
  end

  subject {RightApi::Resources.new(@client, '/api/resources', 'resources')}

  context "attributes" do
    its(:client) {should eq @client}
    its(:path) {should eq '/api/resources'}
    its(:resource_type) {should eq 'resources'}
  end

  context ".inspect" do
    let (:resource) {RightApi::Resources.new(@client, '/api/resources', 'resources')}
    it "should return correct inspect value" do
      inspect_text = "#<#{resource.class.name} resource_type=\"#{resource.resource_type}\">"
      resource.inspect.should == inspect_text
    end
  end

  context ".to_ary" do
    let (:resource) {RightApi::Resources.new(@client, '/api/resources', 'resources')}
    it "should return correct to_array value" do
      to_array_text = ["#<#{resource.class.name} ","resource_type=\"#{resource.resource_type}\">"]
      resource.to_ary.should == to_array_text
    end
  end

  context ".method_missing" do
    let (:resource) {RightApi::Resources.new(@client, '/api/resources', 'resources')}
    it "should do send request with path/method" do
      flexmock(@client).should_receive(:send).with(:do_post, "#{resource.path}/method")
      resource.method_missing("method")
    end
  end

  context "given a logged in RightScale user" do
    it "has the required methods for instances of the Resources class" do
      resource = RightApi::Resources.new(@client, '/api/deployments', 'deployments')
      resource.api_methods.sort.collect(&:to_s).should == %w[
        create index ]
    end

    it "has index even for instances of the Resources class that do not support it" do
      resource = RightApi::Resources.new(@client, '/api/tags', 'tags')
      resource.api_methods.sort.collect(&:to_s).should == %w[
        by_resource by_tag create index multi_add multi_delete ]
    end

    it "has resource-specific methods for instances of the Resources class" do
      resource = RightApi::Resources.new(@client, '/api/backups', 'backups')
      resource.api_methods.sort.collect(&:to_s).should == %w[
        cleanup create index ]
    end
  end
end
