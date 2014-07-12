require File.expand_path('../../spec_helper', __FILE__)

describe RightApi::Resources, :unit=>true do
  context "given a logged in RightScale user" do
    before(:each) do
      given_user_facing_client
    end

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
