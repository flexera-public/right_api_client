# > cd detail_specs
# > bundle exec spec server_template_spec.rb

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client server_templates" do
  before(:all) do
    @client, @server_template_id = get_ids('server_templates')
    @resources = @client.server_templates
    @resource = @client.server_templates(:id => @server_template_id)
    @resource_detail = @resource.show
  end

  it "should return a Resources object for @resources, with resource_type = server_templates" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"server_templates\"")
  end

  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index]
  end

  it "should return an array of Resources for @resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::ResourceDetail)
     @resources.index.first.inspect.should include("resource_type=\"server_template\"")
  end

  it "should return less for the correct filter" do
     @resources.index(:filter => ['name==server_template']).should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:filter => ['name==server_template']).length
     non_filtered.should > filtered
  end

  it "should return a Resource object for @resource, with resource_type = server_template" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"server_template\"")
  end

  it "should return show for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show]
  end

  it "should return a ResourceDetail object for @resource.show, with resource_type = server_template" do
    @resource.show.should be_kind_of(RightApi::ResourceDetail)
    @resource.show.inspect.should include("resource_type=\"server_template\"")
  end

  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:name, :description, :revision, :links, :href, :multi_cloud_images, :inputs].sort
  end




  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)

    @resource_detail.multi_cloud_images.should be_kind_of(RightApi::Resources)
    @resource_detail.multi_cloud_images.inspect.should include("resource_type=\"multi_cloud_images\"")
  end
end
