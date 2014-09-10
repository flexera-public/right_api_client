require File.expand_path('../../spec_helper', __FILE__)

describe RightApi::Resource, :unit=>true do
  before(:each) do
    given_user_facing_client
  end

  subject {RightApi::Resource.new(@client, 'resource', '/api/resource')}

  context "attributes" do
    its(:client) {should eq @client}
    its(:href) {should eq '/api/resource'}
    its(:resource_type) {should eq 'resource'}
  end

  context "#process" do
    it "creates resource_detail with data" do
      flexmock(RightApi::ResourceDetail).should_receive(:new)
      RightApi::Resource.process(@client, 'resource', '/api/resource', :right => ['scale'])
    end

    it "creates resource without data" do
      flexmock(RightApi::Resource).should_receive(:new)
      RightApi::Resource.process(@client, 'resource', '/api/resource')
    end
  end

  context "#process_detailed" do
    it "calls process with data array" do
      flexmock(RightApi::Resource).should_receive(:process)
      RightApi::Resource.process(@client, 'resource', '/api/resource', :right => ['scale'])
    end

    it "calls process with data array" do
      flexmock(RightApi::Resource).should_receive(:process)
      RightApi::Resource.process(@client, 'resource', '/api/resource')
    end

    it "creates new process detail with data links" do
      flexmock(RightApi::ResourceDetail).should_receive(:new)
      RightApi::Resource.process(@client, 'resource', '/api/resource', 'links' => 'scale')
    end
  end

  context ".inspect" do
    let(:resource) {RightApi::Resource.new(@client, 'resource', '/api/resource')}
    it "returns correct inspect text" do
      inspect_text = "#<#{resource.class.name} resource_type=\"#{resource.resource_type}\">"
      resource.inspect.should == inspect_text
    end
  end

  context ".method_missing" do
    it "sends correct post request" do
      client = flexmock(@client)
      resource = RightApi::Resource.new(client, 'resource', '/api/resource')
      client.should_receive(:send).with(:do_post, "#{resource.href}/method")
      resource.method_missing('method')
    end
  end

  context "given a logged in RightScale user" do
    it "has the required methods for instances of the Resource class" do
      resource = RightApi::Resource.process(@client, 'deployment', '/api/deployments/1')
      resource.api_methods.sort.map(&:to_s).should == %w[ destroy show update ]
    end

    it "has destroy/show/update for all instances of the Resource class" do
      resource = RightApi::Resource.process(@client, 'session', '/api/session')
      resource.api_methods.sort.map(&:to_s).should == %w[ destroy show update ]
    end

    it "has an array of ResourceDetail instances for index calls" do
      resources = RightApi::Resource.process(@client, 'deployment', '/api/deployments', [{}])
      resources.first.class.should == RightApi::ResourceDetail
    end
  end
end
