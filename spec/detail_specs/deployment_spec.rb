# > cd detail_specs
# > bundle exec spec deployment_spec.rb 

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client deployments" do
  before(:all) do
    @client, @deployment_id = get_ids('deployments')
    @resources = @client.deployments
    @resource = @client.deployments(:id => @deployment_id)
    @resource_detail = @resource.show
    @resource_detail_view_inputs = @resource.show(:view => 'inputs')
  end
  
  it "should return a Resources object for @resources, with resource_type = deployments" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"deployments\"")
  end
  
  it "should return index, create for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index, :create].sort
  end
  
  it "should return an array of Resources for @resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::Resource)
     @resources.index.first.inspect.should include("resource_type=\"deployment\"")
  end
  
  it "should return less for the correct filter" do
     @resources.index(:filter => ['name==Some really long weird name']).should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:filter => ['name==Some really long weird name']).length
     non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = deployment" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"deployment\"")
  end
  
  it "should return show, update, destroy for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show, :destroy, :update].sort
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = deployment" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"deployment\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:name, :description, :links, :href, :servers, :server_arrays, :inputs].sort
  end
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.servers.should be_kind_of(RightApi::Resources)
    @resource_detail.servers.inspect.should include("resource_type=\"servers\"")
    
    @resource_detail.server_arrays.should be_kind_of(RightApi::Resources)
    @resource_detail.server_arrays.inspect.should include("resource_type=\"server_arrays\"")
    
    @resource_detail.inputs.should be_kind_of(RightApi::Resources)
    @resource_detail.inputs.inspect.should include("resource_type=\"inputs\"")
  end
  
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = deployment" do
    @resource_detail_view_inputs.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail_view_inputs.inspect.should include("resource_type=\"deployment\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail_view_inputs.api_methods.should_not be_empty
    @resource_detail_view_inputs.api_methods.sort.should == [:name, :description, :links, :href, :servers, :server_arrays, :inputs].sort
  end
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail_view_inputs.links.should be_kind_of(Array)
    @resource_detail_view_inputs.href.should be_kind_of(String)
    
    @resource_detail_view_inputs.servers.should be_kind_of(RightApi::Resources)
    @resource_detail_view_inputs.servers.inspect.should include("resource_type=\"servers\"")
    
    @resource_detail_view_inputs.server_arrays.should be_kind_of(RightApi::Resources)
    @resource_detail_view_inputs.server_arrays.inspect.should include("resource_type=\"server_arrays\"")
    
    @resource_detail_view_inputs.inputs.should be_kind_of(RightApi::Resources)
    @resource_detail_view_inputs.inputs.inspect.should include("resource_type=\"inputs\"")
  end
end
