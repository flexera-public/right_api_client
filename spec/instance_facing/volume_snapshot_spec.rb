$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'get_ids'

describe "RightApi::Client volume_snapshots" do
  before(:all) do
    @client, @volume_snapshot_id, @volume_id,  @volume_volume_snapshot_id = get_ids('volume_snapshots')
    
    @resources = @client.volume_snapshots
    @resource = @client.volume_snapshots(:id => @volume_volume_snapshot_id)
    @resource_detail = @resource.show
    
    @resources_volumes = @client.volumes(:id => @volume_id).show.volume_snapshots
    @resource_volumes = @client.volumes(:id => @volume_id).show.volume_snapshots(:id => @volume_volume_snapshot_id)
    @resource_volumes_detail = @resource_volumes.show
  end
  
  
  it "should return a Resources object for @resources, with resource_type = volume_snapshots" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"volume_snapshots\"")
  end
  
  it "should return index, create for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index, :create].sort
  end
  
  it "should return an array of Resources for @resources.index" do
    @resources.index.should be_kind_of(Array)
    @resources.index.first.should be_kind_of(RightApi::ResourceDetail)
    @resources.index.first.inspect.should include("resource_type=\"volume_snapshot\"")
  end
  
  it "should return less for the correct filter" do
    @resources.index(:filter => ['resource_uid==1a']).should be_kind_of(Array)
    non_filtered = @resources.index.length
    filtered = @resources.index(:filter => ['resource_uid==1a']).length
    non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = cloud" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"volume_snapshot\"")
  end
  
  it "should return show, destroy for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show, :destroy].sort
  end
  
  it "should return a ResourceDetail object for @resource_detail, with resource_type = volume_snapshot" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"volume_snapshot\"")
  end
  
  it "should return the correct methods for @resource_detail.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:created_at, :updated_at, :name, :resource_uid, :description, :size, :state, :links, :href, :cloud, :parent_volume].sort
  end
  
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
    
    @resource_detail.parent_volume.should be_kind_of(RightApi::Resource)
    @resource_detail.parent_volume.inspect.should include("resource_type=\"volume\"")
  end
  
  
  # Second way
  it "should return a Resources object for @resources_volumes, with resource_type = volume_snapshots" do
    @resources_volumes.should be_kind_of(RightApi::Resources)
    @resources_volumes.inspect.should include("resource_type=\"volume_snapshots\"")
  end

  it "should return index, create for @resources_volumes.api_methods" do
    @resources_volumes.api_methods.should_not be_empty
    @resources_volumes.api_methods.sort.should == [:index, :create].sort
  end

  it "should return an array of Resources for @resources_volumes.index" do
    @resources_volumes.index.should be_kind_of(Array)
    @resources_volumes.index.first.should be_kind_of(RightApi::Resource)
    @resources_volumes.index.first.inspect.should include("resource_type=\"volume_snapshot\"")
  end

  it "should return less for the correct filter" do
    @resources_volumes.index(:filter => ['resource_uid==1a']).should be_kind_of(Array)
    non_filtered = @resources_volumes.index.length
    filtered = @resources_volumes.index(:filter => ['resource_uid==1a']).length
    non_filtered.should > filtered
  end

  it "should return a Resource object for @resource, with resource_type = cloud" do
    @resource_volumes.should be_kind_of(RightApi::Resource)
    @resource_volumes.inspect.should include("resource_type=\"volume_snapshot\"")
  end

  it "should return show, destroy for @resource_volumes.api_methods" do
    @resource_volumes.api_methods.should_not be_empty
    @resource_volumes.api_methods.sort.should == [:show, :destroy].sort
  end

  it "should return a ResourceDetail object for @resource_volumes_detail, with resource_type = volume_snapshot" do
    @resource_volumes_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_volumes_detail.inspect.should include("resource_type=\"volume_snapshot\"")
  end

  it "should return the correct methods for @resource_volumes_detail.api_methods" do
    @resource_volumes_detail.api_methods.should_not be_empty
    @resource_volumes_detail.api_methods.sort.should == [:created_at, :updated_at, :name, :resource_uid, :description, :size, :state, :links, :href, :cloud, :parent_volume].sort
  end




  it "for each method make sure you can call it" do
    @resource_volumes_detail.links.should be_kind_of(Array)
    @resource_volumes_detail.href.should be_kind_of(String)

    @resource_volumes_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_volumes_detail.cloud.inspect.should include("resource_type=\"cloud\"")

    @resource_volumes_detail.parent_volume.should be_kind_of(RightApi::Resource)
    @resource_volumes_detail.parent_volume.inspect.should include("resource_type=\"volume\"")
  end
end
