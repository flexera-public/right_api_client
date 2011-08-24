$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'get_ids'

describe "RightApi::Client multi_cloud_image_settings" do
  before(:all) do
    @client, @multi_cloud_image_id, @multi_cloud_image_setting_id = get_ids('multi_cloud_image_settings')
    @resources = @client.multi_cloud_images(:id => @multi_cloud_image_id).show.settings
    @resource = @client.multi_cloud_images(:id => @multi_cloud_image_id).show.settings(:id => @multi_cloud_image_setting_id)
    @resource_detail = @resource.show
  end
  
  it "should return a Resources object for @client.resources, with resource_type = multi_cloud_image_settings" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"multi_cloud_image_settings\"")
  end
  
  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index]
  end
  
  it "should return an array of Resources for @resources" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::ResourceDetail)
     @resources.index.first.inspect.should include("resource_type=\"multi_cloud_image_setting\"")
  end
  
  it "should return less for the correct filter" do
     @resources.index(:filter => ['cloud_href==/api/clouds/907']).should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:filter => ['cloud_href==/api/clouds/907']).length
     non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = multi_cloud_image_setting" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"multi_cloud_image_setting\"")
  end
  
  it "should return show for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show]
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = multi_cloud_image_setting" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"multi_cloud_image_setting\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:cloud, :href, :image, :instance_type, :links, :multi_cloud_image, :show].sort
  end
  
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.image.should be_kind_of(RightApi::Resource)
    @resource_detail.image.inspect.should include("resource_type=\"image\"")
    
    @resource_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
    
    @resource_detail.instance_type.should be_kind_of(RightApi::Resource)
    @resource_detail.instance_type.inspect.should include("resource_type=\"instance_type\"")
    
    @resource_detail.multi_cloud_image.should be_kind_of(RightApi::Resource)
    @resource_detail.multi_cloud_image.inspect.should include("resource_type=\"multi_cloud_image\"")  
  end
end
