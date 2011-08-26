require File.expand_path('../spec_helper', __FILE__)
include MockSpecHelper

describe RightApi::Resource do
  context "Given a logged in RightScale user" do
    before(:each) do
      given_user_facing_client
    end

    it "Should have the required methods for instances of the Resource class" do
      resource = RightApi::Resource.process(@client, 'deployment', '/api/deployments/1')
      resource.api_methods.sort.should == [:destroy, :show, :update]
    end

    it "Should not have destroy/show/update for instances of the Resource class that do not support them" do
      resource = RightApi::Resource.process(@client, 'session', '/api/session')
      resource.api_methods.sort.should == []
    end

    it "Should have an array of ResourceDetail instances for index calls" do
      resources = RightApi::Resource.process(@client, 'deployment', '/api/deployments', [{}])
      resources.first.class.should == RightApi::ResourceDetail
    end
  end
end