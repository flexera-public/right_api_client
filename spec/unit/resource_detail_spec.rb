require File.expand_path('../../spec_helper', __FILE__)

describe RightApi::ResourceDetail, :unit=>true do
  before(:each) do
    given_user_facing_client
  end

  subject {RightApi::ResourceDetail.new(@client, 'resource_detail', '/api/resource_detail', {})}

  context "attributes" do
    its(:client) {should eq @client}
    its(:attributes) {should eq Set.new << :links}
    its(:resource_type) {should eq 'resource_detail'}
    its(:associations) {should eq Set.new}
    its(:actions) {should eq Set.new}
    its(:raw) {should eq Hash.new}
  end

  context ".inspect" do
    let(:resource_detail){RightApi::ResourceDetail.new(@client, 'resource_detail', '/api/resource_detail', {})}
    it "returns correct inspect infos" do
      inspect_text = "#<#{resource_detail.class.name} resource_type=\"#{resource_detail.resource_type}\">"
      resource_detail.inspect.should == inspect_text
    end
  end

  context "given a logged in RightScale user" do

    it "has the required methods for instances of the ResourceDetail class" do
      resource = RightApi::ResourceDetail.new(@client, 'deployment', '/api/deployments/1', {})
      resource.api_methods.sort.collect{|s| s.to_s}.should == ["destroy", "links", "show", "update"]
    end

    it "has resource-specific methods for instances of the ResourceDetail class" do
      resource = RightApi::ResourceDetail.new(@client, 'deployment', '/api/deployments/1',
                                              {:attribute1 => 'value1', :attribute2 => 'value2'})
      resource.api_methods.sort.collect{|s| s.to_s}.should == ["attribute1", "attribute2", "destroy", "links", "show", "update"]
    end

    it "has the links for instances of the ResourceDetail class" do
      resource = RightApi::ResourceDetail.new(@client, 'deployment', '/api/deployments/1',
                                              {'links' => [{'rel' => 'link1', 'href' => 'link1_href'},
                                                           {'rel' => 'link2', 'href' => 'link2_href'}]})
      resource.api_methods.sort.collect{|s| s.to_s}.should == ["destroy", "link1", "link2", "links", "show", "update"]
    end

    it "has the actions for instances of the ResourceDetail class" do
      resource = RightApi::ResourceDetail.new(@client, 'deployment', '/api/deployments/1',
                                              {'links' => [{'rel' => 'self', 'href' => 'self'}],
                                               'actions' => [{'rel' => 'action1'}, {'rel' => 'action2'}]})
      resource.api_methods.sort.collect{|s| s.to_s}.should == ["action1", "action2", "destroy", "href", "links", "show", "update"]

      flexmock(@rest_client).should_receive(:post).with({}, @header, Proc).and_return('ok')
      resource.action1.should == 'ok'
    end

    it "has live_tasks for the 'instance' resource" do
      resource = RightApi::ResourceDetail.new(@client, 'instance', '/api/instances/1', {})
      resource.api_methods.sort.collect{|s| s.to_s}.should == ["destroy", "links", "live_tasks", "show", "update"]
      flexmock(RightApi::Resource).should_receive(:process).with(@client, 'live_task', '/api/instances/1/live/tasks/1').and_return('ok')
      resource.live_tasks(:id => '1').should == 'ok'
    end

    it "adds methods for child resources from detailed views" do
      resource = RightApi::ResourceDetail.new(@client, 'server', '/api/servers/1', {
          'links' => [
              {'href' => '/api/servers/1', 'rel' => 'self'},
              {'href' => '/api/clouds/1/instances/1', 'rel' => 'current_instance'}],
          'current_instance' => {'links' => [{'href' => '/api/clouds/1/instances/1', 'rel' => 'self'}]}})
      resource.api_methods.collect{|s| s.to_s}.sort.should == ["current_instance", "destroy", "href", "links", "show", "update"]
    end
  end

  context ".[]" do
    let(:resource) { RightApi::ResourceDetail.new(@client, 'deployment', '/api/deployments/1',
                                            {'links' => [{'rel' => 'link1', 'href' => 'link1_href'}],
                                             'real_attribute'=>'hi mom',
                                             'link1' => 'sneaky'}) }

    it 'reads attributes whose name overlaps with a link' do
      resource['link1'].should == 'sneaky'
      resource.link1.should_not == resource['link1']
    end

    it 'accepts String keys' do
      resource['real_attribute'].should == 'hi mom'
    end

    it 'accepts Symbol keys' do
      resource[:real_attribute].should == 'hi mom'
    end
  end
end
