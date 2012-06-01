
require 'spec_helper'


describe RightApi::Resource do
  context "given a logged in RightScale user" do
    before(:each) do
      given_user_facing_client
    end

    it "should have the required methods for instances of the Resource class" do
      resource = RightApi::Resource.process(@client, 'deployment', '/api/deployments/1')
      resource.api_methods.sort.map(&:to_s).should == %w[ destroy show update ]
    end

    it "should have destroy/show/update for all instances of the Resource class" do
      resource = RightApi::Resource.process(@client, 'session', '/api/session')
      resource.api_methods.sort.map(&:to_s).should == %w[ destroy show update ]
    end

    it "should have an array of ResourceDetail instances for index calls" do
      resources = RightApi::Resource.process(@client, 'deployment', '/api/deployments', [{}])
      resources.first.class.should == RightApi::ResourceDetail
    end
  end
end
