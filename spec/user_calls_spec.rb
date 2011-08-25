require File.expand_path('../../lib/right_api_client', __FILE__)

describe RightApi::Client do
  it "should have CRUD for deployments" do
    pending "need to use flexmock to mock client" do
      client = RightApi::Client.new(:cookies => '')
      resource = RightApi::ResourceDetail.new(client, 'deployment', 'api/deployments/1', {})
      resource.api_methods.sort.should == [:create, :index]
    end
  end
end
