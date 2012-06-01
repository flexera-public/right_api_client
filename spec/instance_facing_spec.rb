
require 'spec_helper'
include MockSpecHelper


describe RightApi::Client do
  context "given an instance-facing logged in RightScale user" do
    before(:each) do
      given_instance_facing_client
    end

    it "should have the required methods for the client" do
      @client.api_methods.sort.collect{|s| s.to_s}.should == ["backups", "get_instance", "live_tasks", "volume_attachments", "volume_snapshots", "volume_types", "volumes"]
    end

    it "should return an instance of the Resource class when user provides an id" do
      @client.volumes(:id => 1).class.should    == RightApi::Resource
      @client.backups(:id => 1).class.should    == RightApi::Resource
      @client.live_tasks(:id => 1).class.should == RightApi::Resource
    end

    it "should return an instance of the Resources class when user does not provide an id" do
      @client.volumes.class.should == RightApi::Resources
      @client.backups.class.should == RightApi::Resources
    end
  end
end
