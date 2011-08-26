require File.expand_path('../spec_helper', __FILE__)
include MockSpecHelper

describe RightApi::Client do
  context "Given a logged in RightScale user using the user facing calls" do
    before(:each) do
      given_user_facing_client
    end

    it "Should have the required methods for instances of the ResourceDetail class" do
      resource = RightApi::ResourceDetail.new(@client, 'deployment', 'api/deployments/1', {})
      resource.api_methods.sort.should == [:destroy, :links, :show, :update]
    end

    it "Should not have destroy/show/update for instances of the ResourceDetail class that do not support them" do
      resource = RightApi::ResourceDetail.new(@client, 'session', 'api/session', {})
      resource.api_methods.sort.should == [:links]
    end

    it "Should have resource-specific methods for instances of the ResourceDetail class" do
      resource = RightApi::ResourceDetail.new(@client, 'deployment', 'api/deployments/1',
                                              {:attribute1 => 'value1', :attribute2 => 'value2'})
      resource.api_methods.sort.should == [:attribute1, :attribute2, :destroy, :links, :show, :update]
    end

    it "Should have the links for instances of the ResourceDetail class" do
      resource = RightApi::ResourceDetail.new(@client, 'deployment', 'api/deployments/1',
                                              {'links' => [{'rel' => 'link1', 'href' => 'link1_href'},
                                                           {'rel' => 'link2', 'href' => 'link2_href'}]})
      resource.api_methods.sort.should == [:destroy, :link1, :link2, :links, :show, :update]
    end

    it "Should have the actions for instances of the ResourceDetail class" do
      resource = RightApi::ResourceDetail.new(@client, 'deployment', 'api/deployments/1',
                                              {'actions' => [{'rel' => 'action1'}, {'rel' => 'action2'}]})
      resource.api_methods.sort.should == [:action1, :action2, :destroy, :links, :show, :update]
    end

  end
end