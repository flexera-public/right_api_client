# > cd detail_specs
# > bundle exec spec datacenter_spec.rb

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client datacenters" do
  before(:all) do
    @client, @cloud_id, @datacenter_id = get_ids('datacenters')
    @resources = @client.clouds(:id => @cloud_id).show.datacenters
    @resource = @client.clouds(:id => @cloud_id).show.datacenters(:id => @datacenter_id)
    @resource_detail = @resource.show
  end


  it "should return a Resources object for @resources, with resource_type = datacenters" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"datacenters\"")
  end

  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index]
  end

  it "should return an array of Resources for @resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::ResourceDetail)
     @resources.index.first.inspect.should include("resource_type=\"datacenter\"")
  end

  it "should return less for the correct filter" do
     @resources.index(:filter => ['name==Some really long weird name']).should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:filter => ['name==Some really long weird name']).length
     non_filtered.should > filtered
  end

  it "should return a Resource object for @resource, with resource_type = datacenter" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"datacenter\"")
  end

  it "should return show for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show]
  end

  it "should return a ResourceDetail object for @resource.show, with resource_type = datacenter" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"datacenter\"")
  end

  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:resource_uid, :name, :description, :links, :href, :cloud].sort
  end




  it "for each method make sure you can call it" do
    @resource_detail = @resource.show

    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)

    @resource_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
  end
end
