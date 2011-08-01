# > cd detail_specs
# > bundle exec spec volume_attachment_spec.rb 

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client volume_attachments" do
  before(:all) do
    @client, @volume_attachment_id, @volume_id, @instance_volume_attachment_id = get_ids('volume_attachments')
    @resources = @client.volume_attachments
    @resource = @client.volume_attachments(:id => @volume_attachment_id)
    @resource_detail = @resource.show
    
    @resource_volume = @client.volumes(:id => @volume_id).show.current_volume_attachment
    @resource_volume_detail = @resource_volume.show
    
    @resources_instance = @client.get_instance.volume_attachments
    @resource_instance = @client.get_instance.volume_attachments(:id => @instance_volume_attachment_id)
    @resource_instance_detail = @resource_instance.show
  end
  
  
  it "should return a Resources object for @resources, with resource_type = volume_attachments" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"volume_attachments\"")
  end
  
  it "should return index, create for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index, :create].sort
  end
  
  it "should return an array of Resources for @resources.index" do
    @resources.index.should be_kind_of(Array)
    @resources.index.first.should be_kind_of(RightApi::Resource)
    @resources.index.first.inspect.should include("resource_type=\"volume_attachment\"")
  end
  
  it "should return less for the correct filter" do
    @resources.index(:filter => ['resource_uid==1a']).should be_kind_of(Array)
    non_filtered = @resources.index.length
    filtered = @resources.index(:filter => ['resource_uid==1a']).length
    non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = volume_attachment" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"volume_attachment\"")
  end
  
  it "should return show, destroy for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show, :destroy].sort
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = volume_attachment" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"volume_attachment\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:created_at, :updated_at, :resource_uid, :state, :device, :links, :href, :cloud, :volume, :instance].sort
  end
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
    
    @resource_detail.volume.should be_kind_of(RightApi::Resource)
    @resource_detail.volume.inspect.should include("resource_type=\"volume\"")
    
    @resource_detail.instance.should be_kind_of(RightApi::Resource)
    @resource_detail.instance.inspect.should include("resource_type=\"instance\"")
    
  end
  
  
  
  # Add in the second way
  it "should return a Resource object for @resource, with resource_type = volume_attachment" do
    @resource_volume.should be_kind_of(RightApi::Resource)
    @resource_volume.inspect.should include("resource_type=\"volume_attachment\"")
  end

  it "should return show, destroy for @resource_volume.api_methods" do
    @resource_volume.api_methods.should_not be_empty
    @resource_volume.api_methods.sort.should == [:show, :destroy].sort
  end

  it "should return a ResourceDetail object for @resource_volume.show, with resource_type = volume_attachment" do
    @resource_volume_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_volume_detail.inspect.should include("resource_type=\"volume_attachment\"")
  end

  it "should return the correct methods for @resource_volume.show.api_methods" do
    @resource_volume_detail.api_methods.should_not be_empty
    @resource_volume_detail.api_methods.sort.should == [:created_at, :updated_at, :resource_uid, :state, :device, :links, :href, :cloud, :volume, :instance].sort
  end




  it "for each method make sure you can call it" do
    @resource_volume_detail.links.should be_kind_of(Array)
    @resource_volume_detail.href.should be_kind_of(String)

    @resource_volume_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_volume_detail.cloud.inspect.should include("resource_type=\"cloud\"")

    @resource_volume_detail.volume.should be_kind_of(RightApi::Resource)
    @resource_volume_detail.volume.inspect.should include("resource_type=\"volume\"")

    @resource_volume_detail.instance.should be_kind_of(RightApi::Resource)
    @resource_volume_detail.instance.inspect.should include("resource_type=\"instance\"")

  end
  
  
  # Add in the third way
  
  it "should return a Resources object for @resources, with resource_type = volume_attachments" do
    @resources_instance.should be_kind_of(RightApi::Resources)
    @resources_instance.inspect.should include("resource_type=\"volume_attachments\"")
  end

  it "should return index, create for @resources_instance.api_methods" do
    @resources_instance.api_methods.should_not be_empty
    @resources_instance.api_methods.sort.should == [:index, :create].sort
  end

  it "should return an array of Resources for @resources_instance.index" do
    @resources_instance.index.should be_kind_of(Array)
    @resources_instance.index.first.should be_kind_of(RightApi::Resource)
    @resources_instance.index.first.inspect.should include("resource_type=\"volume_attachment\"")
  end

  it "should return less for the correct filter" do
    @resources_instance.index(:filter => ['resource_uid==1a']).should be_kind_of(Array)
    non_filtered = @resources_instance.index.length
    filtered = @resources_instance.index(:filter => ['resource_uid==1a']).length
    non_filtered.should > filtered
  end

  it "should return a Resource object for @resource, with resource_type = volume_attachment" do
    @resource_instance.should be_kind_of(RightApi::Resource)
    @resource_instance.inspect.should include("resource_type=\"volume_attachment\"")
  end

  it "should return show, destroy for @resource_instance.api_methods" do
    @resource_instance.api_methods.should_not be_empty
    @resource_instance.api_methods.sort.should == [:show, :destroy].sort
  end

  it "should return a ResourceDetail object for @resource_instance.show, with resource_type = volume_attachment" do
    @resource_instance_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_instance_detail.inspect.should include("resource_type=\"volume_attachment\"")
  end

  it "should return the correct methods for @resource_instance.show.api_methods" do
    @resource_instance_detail.api_methods.should_not be_empty
    @resource_instance_detail.api_methods.sort.should == [:created_at, :updated_at, :resource_uid, :state, :device, :links, :href, :cloud, :volume, :instance].sort
  end


  it "for each method make sure you can call it" do
    @resource_instance_detail.links.should be_kind_of(Array)
    @resource_instance_detail.href.should be_kind_of(String)

    @resource_instance_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_instance_detail.cloud.inspect.should include("resource_type=\"cloud\"")

    @resource_instance_detail.volume.should be_kind_of(RightApi::Resource)
    @resource_instance_detail.volume.inspect.should include("resource_type=\"volume\"")

    @resource_instance_detail.instance.should be_kind_of(RightApi::Resource)
    @resource_instance_detail.instance.inspect.should include("resource_type=\"instance\"")

  end
end
