require File.expand_path('../../spec_helper', __FILE__)

describe RightApi::ResourceDetail, :unit=>true do
  context "given a logged in RightScale user" do
    before(:each) do
      given_user_facing_client
    end

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
end
