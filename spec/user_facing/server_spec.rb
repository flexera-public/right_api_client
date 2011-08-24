$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'get_ids'

describe "RightApi::Client servers" do
  before(:all) do
    @client, @server_id, @deployment_id, @deployment_server_id = get_ids('servers')
    @resources = @client.servers
    @resource = @client.servers(:id => @server_id)
    @resource_detail = @resource.show
    @resource_detail_view_instance_detail = @resource.show(:view => 'instance_detail')
    
    @resources_deployment = @client.deployments(:id => @deployment_id).show.servers
    @resource_deployment = @client.deployments(:id => @deployment_id).show.servers(:id => @deployment_server_id)
    @resource_deployment_detail = @resource_deployment.show
    @resource_deployment_detail_view_instance_detail = @resource_deployment.show(:view => 'instance_detail')
  end
  
  it "should return a Resources object for @resources, with resource_type = servers" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"servers\"")
  end
  
  it "should return index, create for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.sort.should == [:index, :create].sort
  end
  
  it "should return an array of Resources for @resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::ResourceDetail)
     @resources.index.first.inspect.should include("resource_type=\"server\"")
  end
  
  it "should return less for the correct filter" do
     @resources.index(:filter => ['name==Some really long weird name']).should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:filter => ['name==Some really long weird name']).length
     non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = server" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"server\"")
  end
  
  it "should return show, update, destroy for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.sort.should == [:show, :destroy, :update].sort
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = server" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"server\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:created_at, :deployment, :description, :destroy, :href, :launch, :links, :name, :next_instance, :show, :state, :update, :updated_at].sort
  end
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.deployment.should be_kind_of(RightApi::Resource)
    @resource_detail.deployment.inspect.should include("resource_type=\"deployment\"")
    
    @resource_detail.next_instance.should be_kind_of(RightApi::Resource)
    @resource_detail.next_instance.inspect.should include("resource_type=\"instance\"")

  end
  
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = server" do
    @resource_detail_view_instance_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail_view_instance_detail.inspect.should include("resource_type=\"server\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail_view_instance_detail.api_methods.should_not be_empty
    @resource_detail_view_instance_detail.api_methods.sort.should == [:created_at, :deployment, :description, :destroy, :href, :launch, :links, :name, :next_instance, :show, :state, :update, :updated_at].sort
  end
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail_view_instance_detail.links.should be_kind_of(Array)
    @resource_detail_view_instance_detail.href.should be_kind_of(String)
    
    @resource_detail_view_instance_detail.deployment.should be_kind_of(RightApi::Resource)
    @resource_detail_view_instance_detail.deployment.inspect.should include("resource_type=\"deployment\"")
    
    @resource_detail_view_instance_detail.next_instance.should be_kind_of(RightApi::Resource)
    @resource_detail_view_instance_detail.next_instance.inspect.should include("resource_type=\"instance\"")
    
  end
  
  # The second way
  it "should return a Resources object for @resources_deployment, with resource_type = servers" do
    @resources_deployment.should be_kind_of(RightApi::Resources)
    @resources_deployment.inspect.should include("resource_type=\"servers\"")
  end

  it "should return index, create for @resources_deployment.api_methods" do
    @resources_deployment.api_methods.should_not be_empty
    @resources_deployment.api_methods.sort.should == [:index, :create].sort
  end

  it "should return an array of Resources for @resources_deployment.index" do
     @resources_deployment.index.should be_kind_of(Array)
     @resources_deployment.index.first.should be_kind_of(RightApi::ResourceDetail)
     @resources_deployment.index.first.inspect.should include("resource_type=\"server\"")
  end

  it "should return less for the correct filter" do
     @resources_deployment.index(:filter => ['name==Some really long weird name']).should be_kind_of(Array)
     non_filtered = @resources_deployment.index.length
     filtered = @resources_deployment.index(:filter => ['name==Some really long weird name']).length
     non_filtered.should > filtered
  end

  it "should return a Resource object for @resource, with resource_type = server" do
    @resource_deployment.should be_kind_of(RightApi::Resource)
    @resource_deployment.inspect.should include("resource_type=\"server\"")
  end

  it "should return show, update, destroy for @resource_deployment.api_methods" do
    @resource_deployment.api_methods.should_not be_empty
    @resource_deployment.api_methods.sort.should == [:show, :destroy, :update].sort
  end

  it "should return a ResourceDetail object for @resource_deployment.show, with resource_type = server" do
    @resource_deployment_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_deployment_detail.inspect.should include("resource_type=\"server\"")
  end

  it "should return the correct methods for @resource_deployment.show.api_methods" do
    @resource_deployment_detail.api_methods.should_not be_empty
    @resource_deployment_detail.api_methods.sort.should == [:created_at, :deployment, :description, :destroy, :href, :launch, :links, :name, :next_instance, :show, :state, :update, :updated_at].sort
  end



  it "for each method make sure you can call it" do
    @resource_deployment_detail.links.should be_kind_of(Array)
    @resource_deployment_detail.href.should be_kind_of(String)

    @resource_deployment_detail.deployment.should be_kind_of(RightApi::Resource)
    @resource_deployment_detail.deployment.inspect.should include("resource_type=\"deployment\"")

    @resource_deployment_detail.next_instance.should be_kind_of(RightApi::Resource)
    @resource_deployment_detail.next_instance.inspect.should include("resource_type=\"instance\"")

  end


  it "should return a ResourceDetail object for @resource_deployment.show, with resource_type = server" do
    @resource_deployment_detail_view_instance_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_deployment_detail_view_instance_detail.inspect.should include("resource_type=\"server\"")
  end

  it "should return the correct methods for @resource_deployment.show.api_methods" do
    @resource_deployment_detail_view_instance_detail.api_methods.should_not be_empty
    @resource_deployment_detail_view_instance_detail.api_methods.sort.should == [:created_at, :deployment, :description, :destroy, :href, :launch, :links, :name, :next_instance, :show, :state, :update, :updated_at].sort
  end



  it "for each method make sure you can call it" do
    @resource_deployment_detail_view_instance_detail.links.should be_kind_of(Array)
    @resource_deployment_detail_view_instance_detail.href.should be_kind_of(String)

    @resource_deployment_detail_view_instance_detail.deployment.should be_kind_of(RightApi::Resource)
    @resource_deployment_detail_view_instance_detail.deployment.inspect.should include("resource_type=\"deployment\"")

    @resource_deployment_detail_view_instance_detail.next_instance.should be_kind_of(RightApi::Resource)
    @resource_deployment_detail_view_instance_detail.next_instance.inspect.should include("resource_type=\"instance\"")

  end
end
