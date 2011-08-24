$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'get_ids'

describe "RightApi::Client get_instance" do
  before(:all) do
    @client = get_ids('get_instance')
    @resource_detail = @client.get_instance
  end
  
  it "should return a Resource object for @resource, with resource_type = instance" do
    @resource_detail.should be_kind_of(RightApi::ResourceDetail)
    @resource_detail.inspect.should include("resource_type=\"instance\"")
  end
  
  
  it "should return the correct methods for @resource.show.api_methods" do
    @resource_detail.api_methods.should_not be_empty
    @resource_detail.api_methods.sort.should == [:cloud, :created_at, :datacenter, :deployment, :description, :href, :image, :inputs, :instance_type, :kernel_image, :links, :live_tasks, :monitoring_metrics, :monitoring_server, :multi_cloud_image, :name, :os_platform, :parent, :private_dns_names, :private_ip_addresses, :public_dns_names, :public_ip_addresses, :resource_uid, :run_executable, :security_groups, :server_template, :show, :ssh_key, :state, :terminate, :terminated_at, :update, :updated_at, :user_data, :volume_attachments].sort
    
  end
  
  
  
  it "for each method make sure you can call it" do
    @resource_detail.links.should be_kind_of(Array)
    @resource_detail.href.should be_kind_of(String)
    
    @resource_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
    
    @resource_detail.deployment.should be_kind_of(RightApi::Resource)
    @resource_detail.deployment.inspect.should include("resource_type=\"deployment\"")
    
    @resource_detail.datacenter.should be_kind_of(RightApi::Resource)
    @resource_detail.datacenter.inspect.should include("resource_type=\"datacenter\"")
    
    @resource_detail.cloud.should be_kind_of(RightApi::Resource)
    @resource_detail.cloud.inspect.should include("resource_type=\"cloud\"")
    
    @resource_detail.server_template.should be_kind_of(RightApi::Resource)
    @resource_detail.server_template.inspect.should include("resource_type=\"server_template\"")
    
    @resource_detail.multi_cloud_image.should be_kind_of(RightApi::Resource)
    @resource_detail.multi_cloud_image.inspect.should include("resource_type=\"multi_cloud_image\"")
    
    @resource_detail.parent.should be_kind_of(RightApi::Resource)
    @resource_detail.parent.inspect.should include("resource_type=\"server\"")
    
    @resource_detail.volume_attachments.should be_kind_of(RightApi::Resources)
    @resource_detail.volume_attachments.inspect.should include("resource_type=\"volume_attachments\"")
    
    @resource_detail.inputs.should be_kind_of(RightApi::Resources)
    @resource_detail.inputs.inspect.should include("resource_type=\"inputs\"")
    
    @resource_detail.image.should be_kind_of(RightApi::Resource)
    @resource_detail.image.inspect.should include("resource_type=\"image\"")
    
    @resource_detail.monitoring_metrics.should be_kind_of(RightApi::Resources)
    @resource_detail.monitoring_metrics.inspect.should include("resource_type=\"monitoring_metrics\"")
  end
end
