# > cd detail_specs
# > bundle exec spec volume_attachment_spec.rb 

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client volume_attachments" do
  before(:all) do
    @client, @cloud_id, @volume_attachment_id = get_ids('volume_attachments')
    
    #@resource_2 = @client.clouds(:id => @cloud_id).show.volumes(:id => @volume_id).show.current_volume_attachment
    
    #@resources_3 = @client.clouds(:id => @cloud_id).show.instances(:id => @instance_id).show.volume_attachments 
    #@resource_3 = @client.clouds(:id => @cloud_id).show.instances(:id => @instance_id).show.volume_attachments(:id => @instance_volume_attachment_id)
  end
  
  
  it "should return a Resources object for @client.clouds(:id => @cloud_id).show.volume_attachments, with resource_type = volume_attachments" do
    @client.clouds(:id => @cloud_id).show.volume_attachments.should be_kind_of(RightApi::Resources)
    @client.clouds(:id => @cloud_id).show.volume_attachments.inspect.should include("resource_type=\"volume_attachments\"")
    
    #@resources_3.should be_kind_of(RightApi::Resources)
    #@resources_3.inspect.should include("resource_type=\"volume_attachments\"")
  end
  
  it "should return index, create for @client.clouds(:id => @cloud_id).show.volume_attachments.api_methods" do
    @client.clouds(:id => @cloud_id).show.volume_attachments.api_methods.should_not be_empty
    @client.clouds(:id => @cloud_id).show.volume_attachments.api_methods.should include(:index)
    @client.clouds(:id => @cloud_id).show.volume_attachments.api_methods.should include(:create)
    
    #@resources_3.api_methods.should_not be_empty
    #@resources_3.api_methods.should include(:index)
    #@resources_3.api_methods.should include(:create)
  end
  
  it "should return an array of Resources for @client.clouds(:id => @cloud_id).show.volume_attachments.index" do
    @client.clouds(:id => @cloud_id).show.volume_attachments.index.should be_kind_of(Array)
    @client.clouds(:id => @cloud_id).show.volume_attachments.index.first.should be_kind_of(RightApi::Resource)
    @client.clouds(:id => @cloud_id).show.volume_attachments.index.first.inspect.should include("resource_type=\"volume_attachment\"")
     
    #@resources_3.index.should be_kind_of(Array)
    #@resources_3.index.first.should be_kind_of(RightApi::Resource)
    #@resources_3.index.first.inspect.should include("resource_type=\"volume_attachment\"")
  end
  
  it "should return less for the correct filter" do
    @client.clouds(:id => @cloud_id).show.volume_attachments.index(:filter => ['resource_uid==1a']).should be_kind_of(Array)
    non_filtered = @client.clouds(:id => @cloud_id).show.volume_attachments.index.length
    filtered = @client.clouds(:id => @cloud_id).show.volume_attachments.index(:filter => ['resource_uid==1a']).length
    non_filtered.should > filtered
    
    #@resources_3.index(:filter => ['resource_uid==1a']).should be_kind_of(Array)
    #non_filtered = @resources_3.index.length
    #filtered = @resources_3.index(:filter => ['resource_uid==1a']).length
    #non_filtered.should > filtered
  end
  
  it "should return a Resource object for @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id), with resource_type = cloud" do
    @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).should be_kind_of(RightApi::Resource)
    @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).inspect.should include("resource_type=\"volume_attachment\"")
    
    #@resource_3.should be_kind_of(RightApi::Resource)
    #@resource_3.inspect.should include("resource_type=\"volume_attachment\"")
  end
  
  it "should return show, destroy for @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).api_methods" do
    @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).api_methods.should_not be_empty
    @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).api_methods.should include(:show)
    @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).api_methods.should include(:destroy)
    
    #@resource_3.api_methods.should_not be_empty
    #@resource_3.api_methods.should include(:show)
    #@resource_3.api_methods.should include(:destroy)
  end
  
  it "should return a ResourceDetail object for @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).show, with resource_type = volume_attachment" do
    @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).show.should be_kind_of(RightApi::ResourceDetail)
    @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).show.inspect.should include("resource_type=\"volume_attachment\"")
    
    #@resource_3.show.should be_kind_of(RightApi::ResourceDetail)
    #@resource_3.show.inspect.should include("resource_type=\"volume_attachment\"")
  end
  
  it "should return the correct methods for @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).show.api_methods" do
    resource_detail = @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).show
    resource_detail.api_methods.should_not be_empty
    resource_detail.api_methods.should include(:created_at)
    resource_detail.api_methods.should include(:updated_at)
    resource_detail.api_methods.should include(:resource_uid)
    resource_detail.api_methods.should include(:state)
    resource_detail.api_methods.should include(:device)
    resource_detail.api_methods.should include(:links)
    resource_detail.api_methods.should include(:href)
    resource_detail.api_methods.should include(:cloud)
    resource_detail.api_methods.should include(:volume)
    resource_detail.api_methods.should include(:instance)
  end
  
  
  
  
  it "for each method make sure you can call it" do
    resource_detail = @client.clouds(:id => @cloud_id).show.volume_attachments(:id => @volume_attachment_id).show
    
    resource_detail.links.should be_kind_of(Array)
    resource_detail.href.should be_kind_of(String)
    
    resource_detail.cloud.should be_kind_of(RightApi::Resource)
    resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
    
    resource_detail.volume.should be_kind_of(RightApi::Resource)
    resource_detail.volume.inspect.should include("resource_type=\"volume\"")
    
    resource_detail.instance.should be_kind_of(RightApi::Resource)
    resource_detail.instance.inspect.should include("resource_type=\"instance\"")
    
  end
end
