# > cd detail_specs
# > bundle exec spec instance_spec.rb 

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client instances" do
  before(:all) do
    @client, @cloud_id, @instance_id = get_ids('instances')
    @resources = @client.clouds(:id => @cloud_id).show.instances
    @resource =  @client.clouds(:id => @cloud_id).show.instances(:id => @instance_id)
    @resource_detail = @resource.show
  end
  
  
  it "should return a Resources object for @resources, with resource_type = instances" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"instances\"")
  end
  
  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index, :multi_run_executable, :multi_terminate].sort
  end
  
  it "should return an array of Resources for @resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::ResourceDetail)
     @resources.index.first.inspect.should include("resource_type=\"instance\"")
  end
  
  it "should return less for the correct filter" do
     @resources.index(:filter => ['name==1a']).should be_kind_of(Array)
     non_filtered = @client.clouds.index.length
     filtered = @resources.index(:filter => ['name==1a']).length
     non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = instance" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"instance\"")
  end
  
  it "should return show for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show, :update].sort
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = instance" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"instance\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:name, :created_at, :live_tasks, :resource_uid, :state, :public_ip_addresses, :private_ip_addresses, :links, :href, :cloud, :deployment, :server_template, :multi_cloud_image, :parent, :volume_attachments, :inputs, :monitoring_metrics, :updated_at, :launch].sort
  end
  
  
  
  
  it "for each method make sure you can call it" do
    
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
    
    @resource_detail.deployment.should be_kind_of(RightApi::Resource)
    @resource_detail.deployment.inspect.should include("resource_type=\"deployment\"")
    
    @resource_detail.server_template.should be_kind_of(RightApi::Resource)
    @resource_detail.server_template.inspect.should include("resource_type=\"server_template\"")
    
    @resource_detail.multi_cloud_image.should be_kind_of(RightApi::Resource)
    @resource_detail.multi_cloud_image.inspect.should include("resource_type=\"multi_cloud_image\"")
    
    @resource_detail.parent.should be_kind_of(RightApi::Resource)
    @resource_detail.parent.inspect.should include("resource_type=\"server\"")
    
    @resource_detail.volume_attachments.should be_kind_of(RightApi::Resources)
    @resource_detail.volume_attachments.inspect.should include("resource_type=\"volume_attachments\"")
    
    @resource_detail.inputs.should be_kind_of(RightApi::Resources)
    @resource_detail.inputs.inspect.should include("resource_type=\"inputs\"")
    
    @resource_detail.monitoring_metrics.should be_kind_of(RightApi::Resources)
    @resource_detail.monitoring_metrics.inspect.should include("resource_type=\"monitoring_metrics\"")
  end
end
