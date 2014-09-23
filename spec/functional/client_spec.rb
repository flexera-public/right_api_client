require File.expand_path('../../spec_helper', __FILE__)

describe RightApi::Client, :functional=>true do
  before(:each) do
    @rest_client = flexmock("rest_client")
    flexmock(RestClient::Resource).should_receive(:new).and_return(@rest_client)

    cookies = {"cookies" => "cookies"}
    get_response = "session", "{\"links\":[{\"rel\":\"deployments\",\"href\":\"/api/deployments\"}, {\"rel\":\"tags\",\"href\":\"/api/tags\"}],\"message\":\"You have successfully logged into the RightScale API.\"}"
    post_response = flexmock("post_response", :code => 204, :cookies => cookies, :body => " ")
    session = flexmock("session")

    @rest_client.should_receive(:[]).with('/api/session').and_return(session)
    session.should_receive(:get).and_return(get_response)
    session.should_receive(:post).and_return(post_response)

    @client = RightApi::Client.new(:email => "email", :password => "password", :account_id => 60073)
  end

  context "mocking a valid set of credentials" do
    it "logs in" do
      @client.send(:headers)[:cookies].should == {"cookies" => "cookies"}
      @client.cookies.class.should == Hash
      @client.cookies["cookies"].should == "cookies"
      @client.cookies.timestamp.should_not == nil
      @client.session.index.message.should == 'You have successfully logged into the RightScale API.'
    end

    it "logs in with cookies" do
      client = RightApi::Client.new({:cookies => "cookies only"})
      client.cookies.should == "cookies only"
    end

    it "accepts an access_token argument when creating a new client" do
      client = RightApi::Client.new({:access_token => "access token only"})
      client.access_token.should == "access token only"
    end

    it "accepts a refresh_token when creating a new client" do
      client = RightApi::Client.new({:refresh_tokeb=> "refresh token only"})
      client.refresh_token.should == "refresh token only"
    end

    it "post request works" do
      deployment_session = flexmock("Deployment Session")
      deployment_session.should_receive(:post).and_return(1)
      @rest_client.should_receive(:[]).with('/api/deployments').and_return(deployment_session)
      response = @client.deployments.create(:deployment => {:name => "deployment_name"})
      response.should == 1
    end

    it "get request works" do
      deployment_session = flexmock("Deployment Session")
      deployment_session.should_receive(:get).and_return(nil)
      @rest_client.should_receive(:[]).with("/api/deployments/1/to_ary").and_return(deployment_session)
      deployment = @client.deployments(:id => 1)
      deployment.href.should == "/api/deployments/1"
    end

    it "put request works" do
      deployment_session = flexmock("Deployment Session")
      deployment_session.should_receive(:get)
      @rest_client.should_receive(:[]).with("/api/deployments/1/to_ary").and_return(deployment_session)
      deployment = @client.deployments(:id => 1)

      @rest_client.should_receive(:[]).with("/api/deployments/1").and_return(deployment_session)
      deployment_session.should_receive(:put).and_return(1)
      deployment.update(:deployment => {:name => "updated"}).should == 1
    end

    it "delete request works" do
      deployment_session = flexmock("Deployment Session")
      deployment_session.should_receive(:get)
      @rest_client.should_receive(:[]).with("/api/deployments/1/to_ary").and_return(deployment_session)
      deployment = @client.deployments(:id => 1)

      @rest_client.should_receive(:[]).with("/api/deployments/1").and_return(deployment_session)
      deployment_session.should_receive(:delete).and_return(1)
      deployment.destroy.should == 1
    end

    it "special request:adds tag to deployment works" do
      tag_session = flexmock("Tag Session")
      tag_session.should_receive(:post).and_return(1)
      @rest_client.should_receive(:[]).with("/api/tags/multi_add").and_return(tag_session)
      response = @client.tags.multi_add("resource_hrefs[]=/api/deployments/1&tags[]=tag1")
      response.should == 1
    end

    it "singularizes resource_types correctly" do
      @client.get_singular('servers').should == 'server'
      @client.get_singular('deployments').should == 'deployment'
      @client.get_singular('audit_entries').should == 'audit_entry'
      @client.get_singular('processes').should == 'process'
      @client.get_singular('ip_addresses').should == 'ip_address'
    end

    it "returns the resource when calling #resource(href)" do
      resource_session = flexmock("Resource Session")
      response = "deployment","{\"links\":[{\"rel\":\"self\",\"href\":\"/api/deployments/1\"}],\"name\":\"Mock Deployment\"}"
      resource_session.should_receive(:get).and_return(response)
      @rest_client.should_receive(:[]).with("/api/deployments/1").and_return(resource_session)
      deployment = @client.resource("/api/deployments/1")
      deployment.href.should == "/api/deployments/1"
      deployment.name.should == "Mock Deployment"
    end

    it "raises meaningful errors" do
      error_message = flexmock("Error Message", :code => 422, :body => "ERROR")
      @rest_client.should_receive(:[]).with("/api/nada").and_raise(RightApi::UnknownRouteError.new(error_message))
      err = begin
        @client.resource('/api/nada')
      rescue => e
        e
      end

      err.class.should == RightApi::UnknownRouteError
      err.message.should == "Unknown action or route. HTTP Code: 422, Response body: ERROR"
    end

    it "wraps errors with _details" do
      response = flexmock("response", :code => 422, :body => "ResourceNotFound: Couldn't find Deployment with ID=asdf ")
      @rest_client.should_receive(:[]).with("/api/deployments/nada").and_raise(RightApi::ApiError.new(response))
      err = begin
        @client.deployments(:id => 'nada').show
      rescue => e
        e
      end

      err._details.method.should == :get
      err._details.path.should == '/api/deployments/nada'
      err._details.params.should == {}
    end
  end
end
