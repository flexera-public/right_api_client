$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'get_ids'

describe "RightApi::Client volumes" do
  before(:all) do
    @client, @cloud_id, @volume_id = get_ids('volumes')
    @resources = @client.clouds(:id => @cloud_id).show.volumes
    @resource = @client.clouds(:id => @cloud_id).show.volumes(:id => @volume_id)
    @resource_detail = @resource.show
    @resource_detail_extended = @resource.show(:view => 'extended')
  end
  
  it "should return a Resources object for @resources, with resource_type = volumes" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"volumes\"")
  end
  
  it "should return index, create for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index, :create].sort
  end
  
  it "should return an array of Resources for @resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::ResourceDetail)
     @resources.index.first.inspect.should include("resource_type=\"volume\"")
  end
  
  it "should return less for the correct filter" do
     @resources.index(:filter => ['name==1a']).should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:filter => ['name==1a']).length
     non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = cloud" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"volume\"")
  end
  
  it "should return show, destroy for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show, :destroy].sort
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = volume" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"volume\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:created_at, :updated_at, :name, :resource_uid, :size, :description, :status, :links, :href, :cloud, :datacenter, :volume_snapshots, :current_volume_attachment, :parent_volume_snapshot].sort
  end
  
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
    
    @resource_detail.datacenter.should be_kind_of(RightApi::Resource)
    @resource_detail.datacenter.inspect.should include("resource_type=\"datacenter\"")
    
    #@resource_detail.volume_type.should be_kind_of(RightApi::Resource)
    #@resource_detail.volume_type.inspect.should include("resource_type=\"volume_type\"")
    
    @resource_detail.volume_snapshots.should be_kind_of(RightApi::Resources)
    @resource_detail.volume_snapshots.inspect.should include("resource_type=\"volume_snapshots\"")
    
    @resource_detail.current_volume_attachment.should be_kind_of(RightApi::Resource)
    @resource_detail.current_volume_attachment.inspect.should include("resource_type=\"volume_attachment\"")
  end
  
  
  
  it "should return a ResourceDetail object for @resource.show(:view => 'extended'), with resource_type = volume" do
    @resource_detail_extended.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail_extended.inspect.should include("resource_type=\"volume\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail_extended.api_methods.should_not be_empty
    @resource_detail_extended.api_methods.sort.should == [:created_at, :updated_at, :name, :resource_uid, :size, :description, :status, :links, :href, :cloud, :datacenter, :volume_snapshots, :current_volume_attachment, :parent_volume_snapshot].sort
  end
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail_extended.links.should be_kind_of(Array)
    @resource_detail_extended.href.should be_kind_of(String)
    
    @resource_detail_extended.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail_extended.cloud.inspect.should include("resource_type=\"cloud\"")
    
    @resource_detail_extended.datacenter.should be_kind_of(RightApi::Resource)
    @resource_detail_extended.datacenter.inspect.should include("resource_type=\"datacenter\"")
    
    #@resource_detail.volume_type.should be_kind_of(RightApi::Resource)
    #@resource_detail.volume_type.inspect.should include("resource_type=\"volume_type\"")
    
    @resource_detail_extended.volume_snapshots.should be_kind_of(RightApi::Resources)
    @resource_detail_extended.volume_snapshots.inspect.should include("resource_type=\"volume_snapshots\"")
    
    @resource_detail_extended.current_volume_attachment.should be_kind_of(RightApi::Resource)
    @resource_detail_extended.current_volume_attachment.inspect.should include("resource_type=\"volume_attachment\"")
  end
end
