# > cd detail_specs
# > bundle exec spec tag_spec.rb

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client tags" do
  before(:all) do
    @client, @resource_hrefs, @tags = get_ids('tags')
    p @tags
    @resources = @client.tags
    @by_resource = @client.tags.by_resource(:resource_hrefs => @resource_hrefs)
    @by_tag = @client.tags.by_tag(:resource_type => 'servers', :tags => @tags)
  end

  it "should return a Resources object for @resources, with resource_type = tags" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"tags\"")
  end

  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:by_resource, :by_tag, :multi_add, :multi_delete]
  end



  it "should be an Array of resource_details with resource_type = resource_tag" do
    @by_resource.should be_kind_of(Array)
    @by_resource.first.should be_kind_of(RightApi::ResourceDetail)
    @by_resource.first.inspect.should include("resource_type=\"resource_tag\"")
  end


  it "should return methods for @by_resource.first.api_methods" do
    @by_resource.first.api_methods.should_not be_empty
    @by_resource.first.api_methods.sort.should == [:tags, :links, :resource].sort
  end

  it "for each method make sure you can call it" do
    @by_resource.first.links.should be_kind_of(Array)
    @by_resource.first.tags.should be_kind_of(Array)

    @by_resource.first.resource.should be_kind_of(Array)
    @by_resource.first.resource.first.should be_kind_of(RightApi::Resource)
    @by_resource.first.resource.first.inspect.should include("resource_type=\"server\"")
  end

  it "should be an Array of resource_details with resource_type = resource_tag" do
    @by_tag.should be_kind_of(Array)
    @by_tag.first.should be_kind_of(RightApi::ResourceDetail)
    @by_tag.first.inspect.should include("resource_type=\"resource_tag\"")
  end


  it "should return methods for @by_resource.first.api_methods" do
    @by_tag.first.api_methods.should_not be_empty
    @by_tag.first.api_methods.sort.should == [:tags, :links, :resource].sort
  end

  it "for each method make sure you can call it" do
    @by_tag.first.links.should be_kind_of(Array)
    @by_tag.first.tags.should be_kind_of(Array)

    @by_tag.first.resource.should be_kind_of(Array)
    @by_tag.first.resource.first.should be_kind_of(RightApi::Resource)
    @by_tag.first.resource.first.inspect.should include("resource_type=\"server\"")
  end
end
