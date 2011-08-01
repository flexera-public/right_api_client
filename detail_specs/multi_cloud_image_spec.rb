# > cd detail_specs
# > bundle exec spec multi_cloud_image_spec.rb 

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client multi_cloud_images" do
  before(:all) do
    @client, @server_template_id, @server_template_multi_cloud_image_id, @multi_cloud_image_id = get_ids('multi_cloud_images')
    
    @resources = @client.multi_cloud_images
    @resource = @client.multi_cloud_images(:id => @multi_cloud_image_id)
    @resource_detail = @resource.show
    
    @resources_server_template = @client.server_templates(:id => @server_template_id).show.multi_cloud_images
    @resource_server_template  = @client.server_templates(:id => @server_template_id).show.multi_cloud_images(:id => @server_template_multi_cloud_image_id)
    @resource_detail_server_template = @resource_server_template.show
  end
  
  it "should return a Resources object for @resources, with resource_type = multi_cloud_images" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"multi_cloud_images\"")
  end
  
  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index]
  end
  
  it "should return an array of Resources for resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::Resource)
     @resources.index.first.inspect.should include("resource_type=\"multi_cloud_image\"")
  end
  
  it "should return less for the correct filter" do
     @resources.index(:filter => ['name==multi_cloud_image']).should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:filter => ['name==multi_cloud_image']).length
     non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = multi_cloud_image" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"multi_cloud_image\"")
  end
  
  it "should return show for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show]
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = multi_cloud_image" do
    @resource.show.should be_kind_of(RightApi::ResourceDetail)
    @resource.show.inspect.should include("resource_type=\"multi_cloud_image\"")
  end
  
  it "should return the correct methods for @resource_detail.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:name, :description, :revision, :links, :href, :settings].sort
  end
  
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.settings.should be_kind_of(RightApi::Resources)
    @resource_detail.settings.inspect.should include("resource_type=\"multi_cloud_image_settings\"")
  end
  
  
  
  
  # ----------------------------- Can also call this another way ------------------------------------------
  
  
  
  it "should return a Resources object for @resources_server_template, with resource_type = multi_cloud_images" do
    @resources_server_template.should be_kind_of(RightApi::Resources)
    @resources_server_template.inspect.should include("resource_type=\"multi_cloud_images\"")
  end
  
  it "should return index for @resources_server_template.api_methods" do
    @resources_server_template.api_methods.should_not be_empty
    @resources_server_template.api_methods.sort.should == [:index]
  end
  
  it "should return an array of Resources for @resources_server_template.index" do
     @resources_server_template.index.should be_kind_of(Array)
     @resources_server_template.index.first.should be_kind_of(RightApi::Resource)
     @resources_server_template.index.first.inspect.should include("resource_type=\"multi_cloud_image\"")
  end
  
  # it "should return less for the correct filter" do
  #     @resources_server_template.index(:filter => ['name==name to see if filter works']).should be_kind_of(Array)
  #     non_filtered = @resources_server_template.index.length
  #     filtered = @resources_server_template.index(:filter => ['name==some weird name to see if filter works']).length
  #     non_filtered.should > filtered
  #   end
  
  it "should return a Resource object for @resource_server_template, with resource_type = multi_cloud_image" do
    @resource_server_template.should be_kind_of(RightApi::Resource)
    @resource_server_template.inspect.should include("resource_type=\"multi_cloud_image\"")
  end
  
  it "should return show for @resource_server_template.api_methods" do
    @resource_server_template.api_methods.should_not be_empty
    @resource_server_template.api_methods.sort.should == [:show]
  end
  
  it "should return a ResourceDetail object for @resource_detail_server_template, with resource_type = multi_cloud_image" do
    @resource_detail_server_template.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail_server_template.inspect.should include("resource_type=\"multi_cloud_image\"")
  end
  
  it "should return the correct methods for @resource_detail_server_template.api_methods" do
    @resource_detail_server_template.api_methods.should_not be_empty
    @resource_detail_server_template.api_methods.sort.should == [:name, :description, :revision, :links, :href, :settings].sort
  end
  
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail_server_template.links.should be_kind_of(Array)
    @resource_detail_server_template.href.should be_kind_of(String)
    
    @resource_detail_server_template.settings.should be_kind_of(RightApi::Resources)
    @resource_detail_server_template.settings.inspect.should include("resource_type=\"multi_cloud_image_settings\"")
  end
  
  
end
