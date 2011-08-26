require File.expand_path('../spec_helper', __FILE__)
include MockSpecHelper

describe RightApi::Resources do
  context "Given a logged in RightScale user" do
    before(:each) do
      given_user_facing_client
    end

    it "Should have the required methods for instances of the Resources class" do
      resource = RightApi::Resources.new(@client, '/api/deployments', 'deployments')
      resource.api_methods.sort.should == [:create, :index]
    end

    it "Should not have index for instances of the Resources class that do not support it" do
      resource = RightApi::Resources.new(@client, '/api/tags', 'tags')
      resource.api_methods.sort.should == [:by_resource, :by_tag, :multi_add, :multi_delete]
    end

    it "Should have resource-specific methods for instances of the Resources class" do
      resource = RightApi::Resources.new(@client, '/api/backups', 'backups')
      resource.api_methods.sort.should == [:cleanup, :create, :index]
    end
  end
end