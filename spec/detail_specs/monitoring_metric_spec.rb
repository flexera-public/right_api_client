# > cd detail_specs
# > bundle exec spec instance_type_spec.rb 

require File.join(File.dirname(__FILE__), 'get_ids')

describe "RightApi::Client monitoring_metric" do
  before(:all) do
    @client, @cloud_id, @instance_type_id, @monitoring_metric_id= get_ids('monitoring_metric')
    @resources = @client.clouds(:id => @cloud_id).show.instances(:id => @instance_type_id).show.monitoring_metrics
    @resource = @client.clouds(:id => @cloud_id).show.instances(:id => @instance_type_id).show.monitoring_metrics(:id => @monitoring_metric_id)
  end
  
  it "should return a Resources object for @resources, with resource_type = monitoring_metrics" do
    @resources.should be_kind_of(RightApi::Resources)
    @resources.inspect.should include("resource_type=\"monitoring_metrics\"")
  end
  
  it "should return index for @resources.api_methods" do
    @resources.api_methods.should_not be_empty
    @resources.api_methods.should include(:index)
  end
  
  it "should return an array of Resources for @resources.index" do
     @resources.index.should be_kind_of(Array)
     @resources.index.first.should be_kind_of(RightApi::Resource)
     @resources.index.first.inspect.should include("resource_type=\"monitoring_metric\"") 
  end
  
  it "should return less for the correct filter" do
     @resources.index(:size => "small").should be_kind_of(Array)
     non_filtered = @resources.index.length
     filtered = @resources.index(:size => "small").length
     non_filtered.should > filtered
  end
  
  it "should return a Resource object for @resource, with resource_type = monitoring_metric" do
    @resource.should be_kind_of(RightApi::Resource)
    @resource.inspect.should include("resource_type=\"monitoring_metric\"")
  end
  
  it "should return show for @resource.api_methods" do
    @resource.api_methods.should_not be_empty
    @resource.api_methods.should include(:show)
  end
  
  it "should return a ResourceDetail object for @resource.show, with resource_type = monitoring_metric" do
    @resource.show.should be_kind_of(RightApi::ResourceDetail)
    @resource.show.inspect.should include("resource_type=\"monitoring_metric\"")
  end
  
  it "should return the correct methods for @resource.show.api_methods" do
    resource_detail = @resource.show
    resource_detail.api_methods.should_not be_empty
    resource_detail.api_methods.should include(:plugin)
    resource_detail.api_methods.should include(:view)
    resource_detail.api_methods.should include(:graph_href)
    resource_detail.api_methods.should include(:links)
    resource_detail.api_methods.should include(:href)
    resource_detail.api_methods.should include(:data)
  end
  
  
  
  
  it "for each method make sure you can call it" do
    resource_detail = @resource.show
    
    resource_detail.links.should be_kind_of(Array)
    resource_detail.href.should be_kind_of(String)
    
    resource_detail.data.should be_kind_of(RightApi::ResourceDetail)
    resource_detail.data.inspect.should include("resource_type=\"monitoring_metric_data\"")
  end
  
  it "should return the correct methods after calling data" do
    resource_detail = @resource.show
    resource_detail.data.api_methods.should_not be_empty
    
    resource_detail.data.api_methods.should include(:start)
    resource_detail.data.api_methods.should include(:end)
    resource_detail.data.api_methods.should include(:variables_data)
    resource_detail.data.api_methods.should include(:links)
    resource_detail.data.api_methods.should include(:href)
    
    resource_detail.data.variables_data.should be_kind_of(Array)
    resource_detail.data.links.should be_kind_of(Array)
    resource_detail.data.href.should be_kind_of(String)
  end
end
