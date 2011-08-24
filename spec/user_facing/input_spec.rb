$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'get_ids'

describe "RightApi::Client inputs" do
  before(:all) do
    @client, @cloud_id, @instance_id, @deployment_id = get_ids('inputs')
    @resources_instance   = @client.clouds(:id => @cloud_id).show.instances(:id => @instance_id).show.inputs
    @resource_instance_detail = @resources_instance.index.first
    
    @resources_deployment = @client.deployments(:id => @deployment_id).show.inputs
    @resource_deployment_detail = @resources_deployment.index.first
  end
  
  
  it "should return a Resources object for @resources_instance, with resource_type = clouds" do
    @resources_instance.should be_kind_of(RightApi::Resources)
    @resources_instance.inspect.should include("resource_type=\"inputs\"")
  end
  
  it "should return index, multi_update for @resources_instance.api_methods" do
    @resources_instance.api_methods.should_not be_empty
    @resources_instance.api_methods.sort.should  == [:index, :multi_update].sort
  end
  
  it "should return an array of ResourceDetail for @resources_instance.index" do
     @resources_instance.index.should be_kind_of(Array)
     @resources_instance.index.first.should be_kind_of(RightApi::ResourceDetail)
     @resources_instance.index.first.inspect.should include("resource_type=\"input\"")
  end
  
  
  it "should return the correct methods for @resource_instance_detail.api_methods" do

    
    @resource_instance_detail.api_methods.should_not be_empty
    @resource_instance_detail.api_methods.sort.should == [:name, :value, :links].sort
  end
  
  
  it "for each method make sure you can call it" do
    @resource_instance_detail.name.should be_kind_of(String)
    @resource_instance_detail.value.should be_kind_of(String)
    @resource_instance_detail.links.should == []
  end
  
  
  # Way Two
  
  it "should return a Resources object for @resources_deployment, with resource_type = clouds" do
    @resources_deployment.should be_kind_of(RightApi::Resources)
    @resources_deployment.inspect.should include("resource_type=\"inputs\"")
  end

  it "should return index, multi_update for @resources_deployment.api_methods" do
    @resources_deployment.api_methods.should_not be_empty
    @resources_deployment.api_methods.sort.should  == [:index, :multi_update].sort
  end

  it "should return an array of ResourceDetail for @resources_deployment.index" do
     @resources_deployment.index.should be_kind_of(Array)
     @resources_deployment.index.first.should be_kind_of(RightApi::ResourceDetail)
     @resources_deployment.index.first.inspect.should include("resource_type=\"input\"")
  end


  it "should return the correct methods for @resource_deployment_detail.api_methods" do


    @resource_deployment_detail.api_methods.should_not be_empty
    @resource_deployment_detail.api_methods.sort.should == [:name, :value, :links].sort
  end


  it "for each method make sure you can call it" do
    @resource_deployment_detail.name.should be_kind_of(String)
    @resource_deployment_detail.value.should be_kind_of(String)
    @resource_deployment_detail.links.should == []
  end
end
