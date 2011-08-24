# > cd detail_specs
# > bundle exec spec image_spec.rb

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client images" do
  before(:all) do
    @client, @cloud_id, @image_id = get_ids('images')
    @resources =  @client.clouds(:id => @cloud_id).show.images
    @resource = @client.clouds(:id => @cloud_id).show.images(:id => @image_id)
    @resource_detail = @client.clouds(:id => @cloud_id).show.images(:id => @image_id).show
  end

  it "should return a Resources object for @resources, with resource_type = images" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"images\"")
  end

  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index]
  end

  it "should return an array of Resources for @resources.index" do
    @resources.index.should be_kind_of(Array)
    @resources.index.first.should be_kind_of(RightApi::Resource)
    @resources.index.first.inspect.should include("resource_type=\"image\"")
  end

  it "should return less for the correct filter" do
    @resources.index(:filter => ['name==Some name']).should be_kind_of(Array)
    non_filtered = @resources.index.length
    filtered = @resources.index(:filter => ['name==Some name']).length
    non_filtered.should > filtered
  end

  it "should return a Resource object for @resource, with resource_type = cloud" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"image\"")
  end

  it "should return show for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show]
  end

  it "should return a ResourceDetail object for @resource.show, with resource_type = image" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"image\"")
  end

  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:resource_uid, :name, :description, :os_platform, :image_type, :cpu_architecture, :visibility, :virtualization_type, :links, :href, :cloud].sort
  end



  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)


    @resource_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
  end
end
