require File.expand_path('../../spec_helper', __FILE__)

describe RightApi::Client, :functional=>true do

  context "given a valid set of credentials in the config/login.yml file" do

    before(:all) do
      @creds = '../../../config/login.yml'
      begin
        @client = RightApi::Client.new(YAML.load_file(File.expand_path(@creds, __FILE__)))
      rescue => e
        puts "WARNING: The following specs need a valid set of credentials as they are integration tests that can only be done by calling the API server"
        puts e.message
        puts e.backtrace
      end

      # Don't bother to run tests if the client didn't initialize
      @client.should_not be_nil
    end

    it "logs in" do
      @client.send(:headers)[:cookies].should_not be_nil
      @client.session.index.message.should == 'You have successfully logged into the RightScale API.'
    end

    it "returns valid cookies" do
      @client.cookies.class.should == Hash
      @client.cookies['_session_id'].should_not be_nil
      @client.cookies['domain'].should match /rightscale.com$/
      @client.cookies.keys.sort.last.should match /^rs_gbl/ # HACK: not quite sane sanity check
    end

    it "accepts a cookie argument when creating a new client" do
      my_hash = YAML.load_file(File.expand_path(@creds, __FILE__))
      my_hash.delete(:email)
      my_hash.delete(:password)
      my_hash.delete(:cookies)
      my_hash[:cookies] = @client.cookies
      client1 = RightApi::Client.new(my_hash)
      client1.cookies.should == @client.cookies
    end

    it "accepts an access_token argument when creating a new client" do
      my_hash = YAML.load_file(File.expand_path(@creds, __FILE__))
      my_hash.delete(:email)
      my_hash.delete(:password)
      my_hash.delete(:cookies)

      access_token = @client.cookies.detect { |k, _| k =~ /^rs_gbl/ }.last
      access_token.should_not be_nil

      # Transform %3D back into =
      access_token = CGI.unescape(access_token)

      my_hash[:access_token] = access_token
      client1 = RightApi::Client.new(my_hash)
      client1.access_token.should == access_token
    end

    it "timestamps cookies" do

      @client.cookies.timestamp.should_not == nil
    end

    it "keeps track of the cookies all the time" do

      t0 = @client.cookies.timestamp

      @client.deployments.index
      t1 = @client.cookies.timestamp

      t0.to_f.should < t1.to_f
    end

    it "accepts a YAML argument when creating a new client" do
      client2 = RightApi::Client.new(YAML.load_file(File.expand_path(@creds, __FILE__)))
      client2.cookies.should_not == @client.cookies
    end

    it "sends post/get/put/delete requests to the server correctly" do
      deployment_name = "right_api_client functional test #{Time.now.to_s}"
      # create a new deployment
      new_deployment = @client.deployments.create(:deployment => {:name => deployment_name})
      new_deployment.class.should     == RightApi::Resource
      new_deployment.show.name.should == deployment_name

      # verify new deployment
      deployment = @client.deployments(:id => new_deployment.show.href.split('/').last)
      deployment.class.should      == RightApi::Resource
      deployment.show.class.should == RightApi::ResourceDetail
      deployment.show.href.should  == new_deployment.show.href

      # update deployment
      deployment.update(:deployment => {:name => "#{deployment_name} updated"}).should be_nil
      deployment.show.name.should == "#{deployment_name} updated"

      # delete deployment
      deployment.destroy.should be_nil
    end

    # Tags are a bit special as they use POST and return content type so they need specific tests
    it "adds tag to deployment" do
      deployment_name = "right_api_client functional test #{Time.now.to_s}"

      # create a new deployment
      new_deployment = @client.deployments.create(:deployment => {:name => deployment_name})

      # add a tag to deployment
      @client.tags.multi_add("resource_hrefs[]=#{new_deployment.show.href}&tags[]=tag1").should == nil

      # verify tag
      tags = @client.tags.by_resource("resource_hrefs[]=#{new_deployment.show.href}")
      tags.class.should == Array
      tags.first.class.should == RightApi::ResourceDetail
      tags.first.tags.first.should == {"name" => "tag1"}
      tags.first.resource.show.name.should == deployment_name

      # delete deployment
      new_deployment.destroy.should be_nil
    end

    it "singularizes resource_types correctly" do
      @client.get_singular('servers').should == 'server'
      @client.get_singular('deployments').should == 'deployment'
      @client.get_singular('audit_entries').should == 'audit_entry'
      @client.get_singular('processes').should == 'process'
      @client.get_singular('ip_addresses').should == 'ip_address'
    end

    it "returns the resource when calling #resource(href)" do

      d0 = @client.deployments.index.first

      d1 = @client.resource(d0.href)

      d1.href.should == d0.href
    end

    it "raises meaningful errors" do

      err = begin
        @client.resource('/api/nada')
      rescue => e
        e
      end

      err.class.should ==
        RightApi::UnknownRouteError
      err.message.should ==
        "Unknown action or route. HTTP Code: 404, Response body: " +
        "NotFound: No route matches \"/api/nada\" with {:method=>:get}"
    end

    it "wraps errors with _details" do

      err = begin
        @client.deployments(:id => 'nada').show
      rescue => e
        e
      end

      #p err
      #puts err.backtrace

      err._details.method.should == :get
      err._details.path.should == '/api/deployments/nada'
      err._details.params.should == {}

      err._details.request.class.should == RestClient::Request

      err._details.response.code.should == 422
      err._details.response.class.should == String
      err._details.response.should == "ResourceNotFound: Couldn't find Deployment with ID=nada "

      err._details.code.should == 422
    end
  end
end
