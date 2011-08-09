# > cd detail_specs
# > bundle exec spec backup_spec.rb 

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client backups" do
  before(:all) do
    @client, @backup_id, @backup_lineage = get_ids('backups')
    @resources = @client.backups
    @resource = @client.backups(:id => @backup_id)
    @resource_detail = @resource.show
  end
  
  it "should return a Resources object for @resources, with resource_type = backups" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"backups\"")
  end
  
  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index, :create, :cleanup].sort
  end
  
  it "should return an array of Resources for @resources.index" do
     @resources.index(:lineage => @backup_lineage).should be_kind_of(Array)
     @resources.index(:lineage => @backup_lineage).first.should be_kind_of(RightApi::ResourceDetail)
     @resources.index(:lineage => @backup_lineage).first.inspect.should include("resource_type=\"backup\"")
  end
  
  it "should return less for the correct filter" do
     @resources.index(:lineage => @backup_lineage, :filter => ['committed==False']).should be_kind_of(Array)
     non_filtered = @resources.index(:lineage => @backup_lineage).length
     filtered = @resources.index(:lineage => @backup_lineage, :filter => ['committed==False']).length
     non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = backup" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"backup\"")
  end
  
  it "should return show for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show, :update, :destroy].sort
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = backup" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"backup\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:name, :description, :lineage, :from_master, :volume_snapshot_count, :created_at, :completed, :committed, :volume_snapshots, :links, :href, :restore].sort
    
  end
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
  end
end
