# > cd detail_specs
# > bundle exec spec ssh_key_spec.rb

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client ssh_keys" do
  before(:all) do
    @client, @cloud_id, @ssh_key_id = get_ids('ssh_keys')
    @resources = @client.clouds(:id => @cloud_id).show.ssh_keys
    @resource = @client.clouds(:id => @cloud_id).show.ssh_keys(:id => @ssh_key_id)
    @resource_detail = @resource.show
  end


  it "should return a Resources object for @resources, with resource_type = ssh_keys" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"ssh_keys\"")
  end

  it "should return index, create for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index, :create].sort
  end

  it "should return an array of Resources for @resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::ResourceDetail)
     @resources.index.first.inspect.should include("resource_type=\"ssh_key\"")
  end

  it "should return less for the correct filter" do
     @resources.index(:filter => ['resource_uid==1a']).should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:filter => ['resource_uid==1a']).length
     non_filtered.should > filtered
  end

  it "should return a Resource object for @resource, with resource_type = ssh_key" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"ssh_key\"")
  end

  it "should return show, destroy for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show, :destroy].sort
  end

  it "should return a ResourceDetail object for @resource.show, with resource_type = ssh_key" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"ssh_key\"")
  end

  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:resource_uid, :links, :href, :cloud].sort
  end




  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)

    @resource_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
  end
end
