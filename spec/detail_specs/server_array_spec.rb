# > cd detail_specs
# > bundle exec spec server_array_spec.rb 

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client server_arrays" do
  before(:all) do
    @client, @server_array_id = get_ids('server_arrays')
    @resources = @client.server_arrays
    @resource = @client.server_arrays(:id => @server_array_id)
    @resource_detail = @resource.show
  end
  
  it "should return a Resources object for @resources, with resource_type = server_arrays" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"server_arrays\"")
  end
  
  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index, :create].sort
  end
  
  it "should return an array of Resources for @resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::Resource)
     @resources.index.first.inspect.should include("resource_type=\"server_array\"")
  end
  
  it "should return less for the correct filter" do
     @resources.index(:filter => ['name==Some really long weird name']).should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:filter => ['name==Some really long weird name']).length
     non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = server_array" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"server_array\"")
  end
  
  it "should return show for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show, :update, :destroy].sort
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = server_array" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"server_array\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:name, :description, :state, :array_type, :instances_count, :elasticity_params, :links, :href, :deployment, :current_instances, :next_instance, :launch].sort
    
  end
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.deployment.should be_kind_of(RightApi::Resource)
    @resource_detail.deployment.inspect.should include("resource_type=\"deployment\"")
    
    @resource_detail.current_instances.should be_kind_of(RightApi::Resources)
    @resource_detail.current_instances.inspect.should include("resource_type=\"instances\"")
    
    @resource_detail.next_instance.should be_kind_of(RightApi::Resource)
    @resource_detail.next_instance.inspect.should include("resource_type=\"instance\"")
    
  end
end
