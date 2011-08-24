$:.unshift('../lib')
require 'right_api_client'

describe RightApi::Client do
  it "should have CRUD for deployments" do
    client = RightApi::Client.new(:cookies => '')
    resource = RightApi::ResourceDetail.new(client, 'deployment', 'api/deployments/1', {})
    resource.api_methods.sort.should == [:create, :index]
  end
end
