require File.expand_path('../../lib/right_api_client', __FILE__)
require 'spec'
require 'yaml'

describe RightApi::Client do
  context "Given a valid set of credentials in the examples/login.yml file" do
    before(:all) do
      @creds = '../../examples/login.yml'
      begin
        @client = RightApi::Client.new(YAML.load_file(File.expand_path(@creds, __FILE__)))
      rescue Exception => e
        puts "WARNING: The following specs need a valid set of credentials as they are integration tests that can only be done by calling the API server"
        puts e.message
      end
    end

    it "Should login" do
      @client.headers[:cookies].should_not be_nil
      @client.session.index.message.should == 'You have successfully logged into the RightScale API.'
    end

    it "Should return a cookies Hash with a 'domain' and a '_session_id'" do
      @client.cookies.class.should     == Hash
      @client.cookies.keys.sort.should == %w[ _session_id domain rs_gbl ]
    end

    it "Should accept a cookie argument when creating a new client" do
      client1 = RightApi::Client.new(:cookies => @client.cookies)
      client2 = RightApi::Client.new(YAML.load_file(File.expand_path(@creds, __FILE__)))

      client1.cookies.should     == @client.cookies
      client2.cookies.should_not == @client.cookies
    end

    it "Should send post/get/put/delete requests to the server correctly" do
      new_deployment = @client.deployments.create(:deployment => {:name => 'test'})
      new_deployment.class.should     == RightApi::Resource
      new_deployment.show.name.should == 'test'

      deployment = @client.deployments(:id => new_deployment.show.href.split('/').last)
      deployment.class.should      == RightApi::Resource
      deployment.show.class.should == RightApi::ResourceDetail
      deployment.show.href.should  == new_deployment.show.href

      deployment.update(:deployment => {:name => 'test2'}).should be_nil
      deployment.show.name.should == 'test2'

      # Tags are a bit special as they use POST and return content type so they need specific tests
      @client.tags.multi_add("resource_hrefs[]=#{deployment.show.href}&tags[]=tag1").should == ""
      tags = @client.tags.by_resource("resource_hrefs[]=#{deployment.show.href}")
      tags.class.should == Array
      tags.first.class.should == RightApi::ResourceDetail
      tags.first.tags.first.should == {"name" => "tag1"}

      deployment.destroy.should be_nil
    end
  end
end