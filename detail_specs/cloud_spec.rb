# > cd detail_specs
# > bundle exec spec cloud_spec.rb 

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client clouds" do
  before(:all) do
    @client, @cloud_id = get_ids('clouds')
    @resources = @client.clouds
    @resource = @client.clouds(:id => @cloud_id)
    @resource_detail = @resource.show
  end
  
  it "should return a Resources object for @resources, with resource_type = clouds" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"clouds\"")
  end
  
  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index]
  end
  
  it "should return an array of Resources for @resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::Resource)
     @resources.index.first.inspect.should include("resource_type=\"cloud\"")
  end
  
  it "should return less for the correct filter" do
     @resources.index(:filter => ['name==Some really long weird name']).should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:filter => ['name==Some really long weird name']).length
     non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = cloud" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"cloud\"")
  end
  
  it "should return show for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show]
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = cloud" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"cloud\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:name, :description, :links, :href, :datacenters, :instance_types, :security_groups, :instances, :ssh_keys, :images, :volume_attachments, :volume_snapshots, :volumes].sort
    
    # For cloud_id = 907 there are no volume_types
    #@resource.show.api_methods.should include(:volume_types)
  end
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.datacenters.should be_kind_of(RightApi::Resources)
    @resource_detail.datacenters.inspect.should include("resource_type=\"datacenters\"")
    
    @resource_detail.instance_types.should be_kind_of(RightApi::Resources)
    @resource_detail.instance_types.inspect.should include("resource_type=\"instance_types\"")
    
    @resource_detail.security_groups.should be_kind_of(RightApi::Resources)
    @resource_detail.security_groups.inspect.should include("resource_type=\"security_groups\"")
    
    @resource_detail.instances.should be_kind_of(RightApi::Resources)
    @resource_detail.instances.inspect.should include("resource_type=\"instances\"")
    
    @resource_detail.ssh_keys.should be_kind_of(RightApi::Resources)
    @resource_detail.ssh_keys.inspect.should include("resource_type=\"ssh_keys\"")
    
    @resource_detail.images.should be_kind_of(RightApi::Resources)
    @resource_detail.images.inspect.should include("resource_type=\"images\"")
    
    @resource_detail.volume_attachments.should be_kind_of(RightApi::Resources)
    @resource_detail.volume_attachments.inspect.should include("resource_type=\"volume_attachments\"")
    
    @resource_detail.volume_snapshots.should be_kind_of(RightApi::Resources)
    @resource_detail.volume_snapshots.inspect.should include("resource_type=\"volume_snapshots\"")
    
    @resource_detail.volumes.should be_kind_of(RightApi::Resources)
    @resource_detail.volumes.inspect.should include("resource_type=\"volumes\"")
    
  end
end
