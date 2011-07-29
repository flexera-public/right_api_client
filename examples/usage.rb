# This file provides a long list of examples that demonstrate how the
# Right API Client can be used. Un-comment the section you want to try...

require 'bundler/setup' # only needed if you want to use Bundler
require 'yaml' # only needed if you want to put your creds in .yml file

require File.expand_path(File.dirname(__FILE__) + '/../lib/right_api_client/client')

# Read username, password and account_id from file, or you can just pass them
# as arguments when creating a new client.
args = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/login.yml'))

puts "Creating RightScale API Client and logging in..."
# Account ID is available from the browser address bar on this page: dashboard > Settings > Account Settings
client = RightApi::Client.new(:email =>args[:email], :password => args[:password], :account_id => args[:account_id])
puts client.session.show.message
#puts 'Available methods:', client.api_methods
##Can also specify api_url and api_version, which is useful for testing, e.g.:
#client = RightApiClient.new(:email => args[:email], :password => args[:password], :account_id => args[:account_id],
#                            :api_url => 'https://test.rightscale.com', :api_version => '2.0')
##Or you can just tell the client to use an already-authenticated cookie (from another client or session), e.g.:
#client = RightApiClient.new(:cookies => my_already_authenticated_cookies)

# The HTTP calls made by RightApiClient can be logged in two ways:
# Log to a file
#client.log('C:\Users\Ali\Desktop\log.txt')
# Log to SDTOUT, which is usually the screen
#require 'logger'
#client.log(Logger.new(STDOUT))


#puts "\n\n --Backups--"
# puts "\n\n --Create A backup -- "
params = {:backup => {:lineage => "my_lineage", :name => "my Backup", :volume_attachment_hrefs => ["/api/clouds/907/volume_attachments/BO7026O3JDKMB", "/api/clouds/907/volume_attachments/31AD6V5JJLN95"]}}
b = @client.backups.create(params)

# Index
@client.backups
@client.backups.api_methods
@client.backups.index(:lineage => "my_lineage")
@client.backups.index(:lineage => "my_lineage")

# Show
@client.backups(:id => 'e1a4006c-ad82-11e0-a428-12313b000806')
@client.backups(:id => 'e1a4006c-ad82-11e0-a428-12313b000806').api_methods
@client.backups(:id => 'e1a4006c-ad82-11e0-a428-12313b000806').show

# Update
params = {:backup => {:committed => "true"}}
@client.backups(:id => '3a7be1ca-ad9a-11e0-947f-12313b000806').update(params)

# cleanup
# Note committed need to be true
params = {:keep_last => "1", :lineage => "my_lineage"}
@client.backups.cleanup(params)

# Destroy
@client.backups(:id => '3a7be1ca-ad9a-11e0-947f-12313b000806').destroy

# Restore
params = {:instance_href => "/api/clouds/907/instances/26B8QNKI4UOLD"}
task = client.backups(:id => '02175dd2-ad9f-11e0-877a-12313b000806').show.restore(params)



puts "\n\n--Clouds--"
# Index, show
# View the methods avaliable to the root resource clouds:
@client.clouds
@client.clouds.api_methods
# Index
@client.clouds.index
@client.clouds.index(:filter => ['name==Cloud'])
# Get the cloud resource
@client.clouds.index(:filter => ['name==Cloud']).first
@client.clouds(:id => 907)
# View the methods avaliable to this cloud
@client.clouds(:id => 907).api_methods
# Follow the show
@client.clouds(:id => 907).show
@client.clouds(:id => 907).show.api_methods


puts "\n\nDatacenters"
# Index, show
# View the methods avaliable to the root resource datacenters
@client.clouds(:id => 907).show.datacenters
@client.clouds(:id => 907).show.datacenters.api_methods
## Index
@client.clouds(:id => 907).show.datacenters.index
@client.clouds(:id => 907).show.datacenters.index(:filter => ['name==us-west-1a'])
## Get the datacenter resource
@client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS')
# View the methods avaliable to this datacenter
@client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').api_methods
# Follow the show
@client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show
@client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.api_methods
# Follow the methods
@client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.href
@client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.links
@client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.cloud.api_methods
@client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.description
@client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.name
@client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.resource_uid


puts "\n\n--Deployments--"
# Index, show, create, update, destroy
# View the methods avaliable to the root resource Deployments
@client.deployments
@client.deployments.api_methods
## Index
@client.deployments.index
@client.deployments.index(:filter => ['name==ns'])
## Show
@client.deployments(:id => '66641')
@client.deployments(:id => '66641').show(:view => 'inputs')
# View the methods avaliable to this deployment
@client.deployments(:id => '66641').api_methods
# Follow the show
@client.deployments(:id => '66641').show
@client.deployments(:id => '66641').show.api_methods
# Follow the methods
@client.deployments(:id => '66641').show.links
@client.deployments(:id => '66641').show.servers.api_methods
@client.deployments(:id => '66641').show.servers.index
@client.deployments(:id => '66641').show.server_arrays.api_methods
@client.deployments(:id => '66641').show.inputs.api_methods
@client.deployments(:id => '66641').show.description
@client.deployments(:id => '66641').show.name
@client.deployments(:id => '66641').show.href
# Create a deployment
params = {:deployment => {:name => 'ClientDeployment', :description => 'This is a client test deployment.'}}
deployment = @client.deployments.create(params)
id = deployment.show.href.split("/")[-1]
@client.deployments(:id => id).show.name
# Update a deployment
params = {:deployment => {:name => 'MyNewClientDeploymentName', :description => 'This is my updated client test deployment.'}} 
@client.deployments(:id => id).update(params)
@client.deployments(:id => id).show.name
# Destroy a deployment
@client.deployments(:id => id).destroy
# Servers:
@client.deployments(:id => '66641').show.servers.api_methods
@client.deployments(:id => '66641').show.servers.index

puts "\n\n--Images--"
# Index, show
# View the methods avaliable to the root resource images
@client.clouds(:id => 907).show.images.api_methods
## Index
@client.clouds(:id => 907).show.images.index
@client.clouds(:id => 907).show.images.index(:filter => ['name==ubuntu'])
@client.clouds(:id => 907).show.images.index(:filter => ['name==ubuntu']).first.show.href
## Show
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95')
# View the methods avaliable to this datacenter
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').api_methods
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.api_methods
# Follow the methods
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.links
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.cloud.api_methods
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.description
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.visibility
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.virtualization_type
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.os_platform
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.name
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.resource_uid
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.cpu_architecture
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.image_type
@client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.href



puts "\n\n--Inputs--"
#Index, multi_update
# View the methods avaliable to the root resource images
# Two ways to do it
@client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.api_methods
@client.deployments(:id => 79259).show.inputs.api_methods
## Index
@client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index
@client.deployments(:id => 79259).show.inputs.index
@client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.api_methods
@client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.links
@client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.name
@client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.value
# MultiUpdate
## Two ways to do it
@client.deployments(:id => 79259).show.inputs.multi_update("inputs[][name]=TEST_NAME&inputs[][value]=text:MyNewValue")
@client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').inputs.multi_update("inputs[][name]=TEST_NAME&inputs[][value]=text:MyNewValue")
@client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.name
@client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.value


puts "\n\n--InstanceTypes--"
# Index, show
# View the methods avaliable to the root resource instance_types
@client.clouds(:id => 907).show.instance_types.api_methods
## Index
@client.clouds(:id => 907).show.instance_types.index
@client.clouds(:id => 907).show.instance_types.index(:filter => ['name==medium'])
## Show
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1')
# View the methods avaliable to this instance_types
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').api_methods
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.api_methods
# Follow the methods
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.links
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.cloud.api_methods
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.local_disk_size
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.cpu_count
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.local_disks
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.memory
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.resource_uid
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.cpu_architecture
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.cpu_speed
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.description
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.name
@client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.href



puts "\n\n--Instances--"

## Index
# Two ways to do it
@client.clouds(:id => 907).show.instances
@client.clouds(:id => 907).show.instances.api_methods
@client.clouds(:id => 907).show.instances.index

@client.server_arrays(:id => 13356).show.current_instances
## Show
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV')
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').api_methods
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show(:view => 'full').api_methods

## "--RunExecutable--"
## Ideally, we want to be able to define script/instance inputs in a params hash like so:
## params = { 
##   :right_script_href => "https://my.rightscale.com/api/right_scripts/296533",
##   :inputs => [
##     {:name => "TEST_NAME1" , :value => "text:VAL1"},
##     {:name => "TEST_NAME2", :value => "text:VAL2"}
##   ]
## }
## But due to how the inputs are expected by the API we can't do this, so we instead have
## to define them manually like in the following call. run_executable returns a task resource (see Tasks example code).
task = @client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.run_executable("right_script_href=/api/right_scripts/371421" +"&inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1")
task.api_methods
task.show.api_methods
# To get updated info need to requery again:
id = task.show.href.split('/')[-1]
task = @client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.live_tasks(:id => id)
task.show.summary
#
#puts "--MultiRunExecutable--"
task = @client.clouds(:id => 907).show.instances.index(:filter => ['name==ns_server5']).multi_run_executable("right_script_href=/api/right_scripts/371421" +"&inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1")
task.api_methods
task.show.api_methods

#puts "--Reboot--"
# Two ways
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.reboot

@client.servers(:id => 967094).show.reboot

#puts "--Launch--"
## Multiple inputs are a bit tricky to define and have to be in this format:
inputs = "inputs[][name]=TEST_NAME&inputs[][value]=text:MyValue&inputs[][name]=rs_utils/timezone&inputs[][value]=text:GMT"
server = @client.clouds(:id => 907).show.instances(:id => '9O2GFF4A43CPT').show.launch(inputs)

#puts "--Update--"
params = {:instance => {:datacenter_href => @client.clouds(:id => 907).show.datacenters.index(:filter => ['name==us-west-1b']).first.show.href}}
@client.clouds(:id => 907).show.instances(:id => '9O2GFF4A43CPT').update(params)

#puts "--MultiTerminate--"
task = @client.clouds(:id => 907).show.instances.multi_terminate(:filter => ['name==ns_server4'])
task.api_methods
task.show.api_methods

# Terminate
@client.clouds(:id => 907).show.instances(:id => '9O2GFF4A43CPT').show.terminate
#The instance.terminated_at value is available in the extended or full view, but you have to filter and search for your instance first.
@client.clouds(:id => 716).show(:view => 'extended', :filter => ['state==inactive', 'resource_uid==7I0K1GBTJ2I2T']).terminated_at





puts "\n\n--MonitoringMetics--"
# Index, show, data
# View the methods avaliable to the root resource instance_types
@client.clouds(:id => 907).show.instances(:id => 'ES29I0BO32AJ1').show.monitoring_metrics
## Index
@client.clouds(:id => 907).show.instances(:id => 'ES29I0BO32AJ1').show.monitoring_metrics.api_methods
@client.clouds(:id => 907).show.instances(:id => 'ES29I0BO32AJ1').show.monitoring_metrics.index
## Show
@client.clouds(:id => 232).show.instances(:id => '5Q1V4V35A2C5K').show.monitoring_metrics.index.last.show.href
# data
@client.clouds(:id => 232).show.instances(:id => '5Q1V4V35A2C5K').show.monitoring_metrics(:id => 'dsfdsf').show.data
@client.clouds(:id => 232).show.instances(:id => '5Q1V4V35A2C5K').show.monitoring_metrics(:id => 'dsfdsf').show.data.api_methods
@client.clouds(:id => 232).show.instances(:id => '5Q1V4V35A2C5K').show.monitoring_metrics(:id => 'dsfdsf').show.data.href

#"--MultiCloudImageSettings--"
# Index, show
# Index
@client.multi_cloud_images.index.first.show.settings
@client.multi_cloud_images(:id => 52426).show.settings.api_methods
@client.multi_cloud_images(:id => 52426).show.settings.index
# Show
@client.multi_cloud_images(:id => 52426).show.settings(:id => 120991)
@client.multi_cloud_images(:id => 52426).show.settings(:id => 120991).api_methods
@client.multi_cloud_images(:id => 52426).show.settings(:id => 120991).show
@client.multi_cloud_images(:id => 52426).show.settings(:id => 120991).show.api_methods

# --MultiCloudImages
# Index, show
# Index
# Two ways
@client.multi_cloud_images
@client.multi_cloud_images.api_methods
@client.multi_cloud_images.index

@client.server_templates(:id => 2).show.multi_cloud_images
@client.server_templates(:id => 2).show.multi_cloud_images.api_methods
@client.server_templates(:id => 2).show.multi_cloud_images.index
# Show
# Two ways
@client.multi_cloud_images(:id => 52426)
@client.multi_cloud_images(:id => 52426).api_methods
@client.multi_cloud_images(:id => 52426).show
@client.multi_cloud_images(:id => 52426).show.api_methods

@client.server_templates(:id => 2).show.multi_cloud_images(:id => 7099)
@client.server_templates(:id => 2).show.multi_cloud_images(:id => 7099).api_methods
@client.server_templates(:id => 2).show.multi_cloud_images(:id => 7099).show
@client.server_templates(:id => 2).show.multi_cloud_images(:id => 7099).show.api_methods
#:links, :settings, :revision, :description, :name, :href



# "--SecurityGroups--"
## Index
@client.clouds(:id => 907).show.security_groups
@client.clouds(:id => 907).show.security_groups.api_methods
@client.clouds(:id => 907).show.security_groups.index
## Show
@client.clouds(:id => 907).show.security_groups(:id => 'CCCFLO89QS4QQ')
@client.clouds(:id => 907).show.security_groups(:id => 'CCCFLO89QS4QQ').api_methods
@client.clouds(:id => 907).show.security_groups(:id => 'CCCFLO89QS4QQ').show
@client.clouds(:id => 907).show.security_groups(:id => 'CCCFLO89QS4QQ').show.api_methods
@client.clouds(:id => 907).show.security_groups(:id => 'CCCFLO89QS4QQ').show(:view => 'tiny').api_methods
#:links, :cloud, :name, :resource_uid, :href



#puts "\n\n--ServerArrays--"
## Index  (two ways to do it)
@client.server_arrays
@client.server_arrays.api_methods
@client.server_arrays.index

@client.deployments(:id => '89065').show.server_arrays
@client.deployments(:id => '89065').show.server_arrays.api_methods
@client.deployments(:id => '89065').show.server_arrays.index
## Show
@client.server_arrays(:id => '13356')
@client.server_arrays(:id => '13356').api_methods
@client.server_arrays(:id => '13356').show
@client.server_arrays(:id => '13356').show.api_methods

@client.deployments(:id => '89065').show.server_arrays(:id => 13356)
@client.deployments(:id => '89065').show.server_arrays(:id => 13356).api_methods
@client.deployments(:id => '89065').show.server_arrays(:id => 13356).show


#puts "--Create--"
server_template_href = @client.server_templates.index(:filter => ['name==Base ServerTemplate All Clouds - QA']).first.show.href
cloud_href = @client.clouds(:id => 907).show.href
deployment_href = @client.deployments(:id => 89065).show.href
security_group_hrefs = [@client.clouds(:id => 907).show.security_groups.index(:filter => ['name==default']).first.show.href]
datacenter_href = @client.clouds(:id => 907).show.datacenters.index.first.show.href
params = { :server_array => {
  :array_type => 'alert',
  :deployment_href => deployment_href,
  :name => 'MyClientServerArray',
  :description => 'This is my server array.',
  :state => 'disabled',
  :elasticity_params => {
    :alert_specific_params => {
      :decision_threshold => 51
    },
    :bounds => {
      :max_count => 3,
      :min_count => 1
    },
    :pacing => {
      :resize_calm_time => 5,
      :resize_down_by => 1,
      :resize_up_by => 1
    }
  },
  :instance => {
    :server_template_href => server_template_href,
    :cloud_href => cloud_href,
    :security_group_hrefs => security_group_hrefs,
    :datacenter_href => datacenter_href
  }  
}}

new_server_array = @client.server_arrays.create(params)
new_server_array.api_methods
#
# You can also create server_array from a specific deployment, where :deployment_href param isn't needed
new_server_array = @client.deployments(:id => 89065).show.server_arrays.create(params)
new_server_array.api_methods

id = new_server_array.show.href.split('/')[-1]
#puts "--Launch--"
## Inputs are a bit tricky so they have to be set in a long string in the this format.
inputs = "inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1&inputs[][name]=rs_utils/timezone&inputs[][value]=text:GMT"
@client.server_arrays(:id => id).show.launch(inputs)
#
#puts "--Update--"
params = {
  :server_array => { 
    :name => 'MyUltraNewServerArrayName'
  }
}
@client.server_arrays(:id => id).update(params)
# or
@client.deployments(:id => '89065').show.server_arrays(:id => id).update(params)

#puts "--MultiRunExecutable--"
task = client.server_arrays(:id => id).multi_run_executable("right_script_href=/api/right_scripts/371421" +"&inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1")
task.api_methods
task.api_methods.show.api_methods

#
#puts "--MultiTerminate--"
task = @client.server_arrays(:id => id).multi_terminate
task.api_methods
task.api_methods.show.api_methods

#
# Destroy (two ways to do it)
@client.server_arrays(:id => id).destroy
@client.deployments(:id => 89065).show.server_arrays(:id => id).destroy



# ServerTemplates
#Index
@client.server_templates
@client.server_templates.api_methods
@client.server_templates.index
#Show
@client.server_templates(:id => 2)
@client.server_templates(:id => 2).api_methods
@client.server_templates(:id => 2).show
@client.server_templates(:id => 2).show.api_methods



#puts "\n\n--Servers--"
# Index (two ways to do it)
@client.servers
@client.servers.api_methods
@client.servers.index

@client.deployments(:id => '89065').show.servers
@client.deployments(:id => '89065').show.servers.api_methods
@client.deployments(:id => '89065').show.servers.index

## Show (two ways to do it) 
@client.servers(:id => 967094)
@client.servers(:id => 967094).api_methods
@client.servers(:id => 967094).show
@client.servers(:id => 967094).show.api_methods

@client.deployments(:id => '89065').show.servers(:id => '967094')
@client.deployments(:id => '89065').show.servers(:id => '967094').api_methods
@client.deployments(:id => '89065').show.servers(:id => '967094').show(:view => 'instance_detail')
@client.deployments(:id => '89065').show.servers(:id => '967094').show(:view => 'instance_detail').api_methods

#puts "--Create--"
server_template_href = @client.server_templates.index(:filter => ['name==Base ServerTemplate All Clouds - QA']).first.show.href
cloud_href = @client.clouds(:id => 907).show.href
deployment_href = @client.deployments(:id => 89065).show.href
security_group_hrefs = [@client.clouds(:id => 907).show.security_groups.index(:filter => ['name==default']).first.show.href]
datacenter_href = @client.clouds(:id => 907).show.datacenters.index.first.show.href

params = { :server => {:name => 'The Ultra Client Server Test', :deployment_href => deployment_href, :instance => {:server_template_href => server_template_href, :cloud_href => cloud_href, :security_group_hrefs => security_group_hrefs, :datacenter_href => datacenter_href}}}
new_server = @client.servers.create(params)
new_server.api_methods
## You can also create server from a specific deployment, where :deployment_href param isn't needed
new_server = @client.deployments(:id => 89065).show.servers.create(params)
new_server.api_methods

id = new_server.show.href.split('/')[-1]
#puts "--Launch--"
## Inputs are a bit tricky so they have to be set in a long string in the this format.
inputs = "inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1&inputs[][name]=rs_utils/timezone&inputs[][value]=text:GMT"
@client.servers.index(:filter => ['name==The Ultra Client Server Test']).first.show.launch(inputs)
#
#puts "--Update--"
# Two ways
params = {:server => {:name => 'NewServerName'}}
@client.servers(:id => id).update(params)

@client.deployments(:id => '89065').show.servers(:id => id).update(params)

# Destroy (two ways to do it)
@client.servers(:id => id).destroy
@client.deployments(:id => 89065).show.servers(:id => id).destroy

#Terminate
@client.servers(:id => 967079).show.terminate



#"--SshKeys--"
# Index, show, create, destroy
## Index
@client.clouds(:id => 907).show.ssh_keys
@client.clouds(:id => 907).show.ssh_keys.api_methods
@client.clouds(:id => 907).show.ssh_keys.index
# Create
params = {:ssh_key => {:name => 'MySshKey'}}
resource = @client.clouds(:id => 907).show.ssh_keys.create(params)
id = resource.show.href.split('/')[-1]
## Show
@client.clouds(:id => 907).show.ssh_keys(:id => id)
@client.clouds(:id => 907).show.ssh_keys(:id => id).api_methods
@client.clouds(:id => 907).show.ssh_keys(:id => id).show
@client.clouds(:id => 907).show.ssh_keys(:id => id).show.api_methods
# :links, :cloud, :resource_uid, :href
# Destroy
@client.clouds(:id => 907).show.ssh_keys(:id => id).destroy





#"--Tags--"
@client.tags.api_methods
# by_resource
@client.tags.by_resource(:resource_hrefs => ['/api/servers/967094', '/api/servers/967078'])
@client.tags.by_resource(:resource_hrefs => ['/api/servers/967094']).first.api_methods
@client.tags.by_resource(:resource_hrefs => ['/api/servers/967094']).first.resource.api_methods
# by_tag
@client.tags.by_tag(:resource_type => 'servers', :tags => ['ns_tag']).first
@client.tags.by_tag(:resource_type => 'servers', :tags => ['ns_tag']).first.api_methods
@client.tags.by_tag(:resource_type => 'servers', :tags => ['ns_tag']).first.resource.first.api_methods
#multi_add
@client.tags.multi_add(:resource_hrefs => ['/api/servers/967078'], :tags => ['client_tag'])
#multi_delete
@client.tags.multi_delete(:resource_hrefs => ['/api/servers/967098'], :tags => ['client_tag'])


# Volume_attachments
# Index
# Two ways
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.volume_attachments
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.volume_attachments.api_methods
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.volume_attachments.index

@client.clouds(:id => 907).show.volume_attachments
@client.clouds(:id => 907).show.volume_attachments.api_methods
@client.clouds(:id => 907).show.volume_attachments.index

# Show
# Three ways to do it
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.volume_attachments(:id => 'BAO92HS0PASUR')
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.volume_attachments(:id => 'BAO92HS0PASUR').api_methods
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.volume_attachments(:id => 'BAO92HS0PASUR').show
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.volume_attachments(:id => 'BAO92HS0PASUR').show.api_methods

@client.clouds(:id => 907).show.volume_attachments(:id => 'BAO92HS0PASUR')
@client.clouds(:id => 907).show.volume_attachments(:id => 'BAO92HS0PASUR').api_methods
@client.clouds(:id => 907).show.volume_attachments(:id => 'BAO92HS0PASUR').show
@client.clouds(:id => 907).show.volume_attachments(:id => 'BAO92HS0PASUR').show.api_methods

@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.current_volume_attachment
@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.current_volume_attachment.api_methods
@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.current_volume_attachment.show
@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.current_volume_attachment.show.api_methods

# Create
instance_href = @client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.href
volume_href = @client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.href
params = {:volume_attachment => {:instance_href => instance_href, :volume_href => volume_href, :device => '/dev/sdk'}}

@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.volume_attachments.create(params)

@client.clouds(:id => 907).show.volume_attachments.create(params)

@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.current_volume_attachment

# Destroy
@client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.volume_attachments(:id => 'BAO92HS0PASUR').destroy

@client.clouds(:id => 907).show.volume_attachments(:id => 'BAO92HS0PASUR').destroy

@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.current_volume_attachment.destroy




# Volume_snapshots
# Index
# Two ways
@client.clouds(:id => 907).show.volume_snapshots
@client.clouds(:id => 907).show.volume_snapshots.api_methods
@client.clouds(:id => 907).show.volume_snapshots.index
id = @client.clouds(:id => 907).show.volume_snapshots.index.first.show.href.split('/')[-1]

@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.volume_snapshots
@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.volume_snapshots.api_methods
@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.volume_snapshots.index

# Show
# Two ways
@client.clouds(:id => 907).show.volume_snapshots(:id => id)
@client.clouds(:id => 907).show.volume_snapshots(:id => id).api_methods
@client.clouds(:id => 907).show.volume_snapshots(:id => id).show
@client.clouds(:id => 907).show.volume_snapshots(:id => id).show.api_methods

@client.clouds(:id => 907).show.volumes(:id => 'AGC6G2PSSUVVD').show.volume_snapshots(:id => 'CMTFBMGLTRU5S')
@client.clouds(:id => 907).show.volumes(:id => 'AGC6G2PSSUVVD').show.volume_snapshots(:id => 'CMTFBMGLTRU5S').api_methods
@client.clouds(:id => 907).show.volumes(:id => 'AGC6G2PSSUVVD').show.volume_snapshots(:id => 'CMTFBMGLTRU5S').show
@client.clouds(:id => 907).show.volumes(:id => 'AGC6G2PSSUVVD').show.volume_snapshots(:id => 'CMTFBMGLTRU5S').show.api_methods

 

# Create
# Two ways
params = {:volume_snapshot => {:name => 'Client test volume snapshot'}}
snap = @client.clouds(:id => 907).show.volume_snapshots.create(params)

snap = @client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.volume_snapshots.create(params)
id = snap.show.href.split('/')[-1]

# Destroy
# Two ways
@client.clouds(:id => 907).show.volume_snapshots(:id => id).destroy

@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.volume_snapshots(:id => id).destroy



# Volume_types
# Index
@client.clouds(:id => 716).show.volume_types
@client.clouds(:id => 716).show.volume_types.api_methods
@client.clouds(:id => 716).show.volume_types.index
id = @client.clouds(:id => 716).show.volume_types.index.first.show.href.split('/')[-1]

#Show
@client.clouds(:id => 716).show.volume_types(:id => id)
@client.clouds(:id => 716).show.volume_types(:id => id).api_methods
@client.clouds(:id => 716).show.volume_types(:id => id).show
@client.clouds(:id => 716).show.volume_types(:id => id).show.api_methods

# Volumes
#Index
@client.clouds(:id => 907).show.volumes
@client.clouds(:id => 907).show.volumes.api_methods
@client.clouds(:id => 907).show.volumes.index
@client.clouds(:id => 907).show.volumes.index(:filter => ['resource_uid==vol-92b504fd']).first.show.href


#Show
@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M')
@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').api_methods
@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show
@client.clouds(:id => 907).show.volumes(:id => '2QQBRFJUIUI3M').show.api_methods

#create
datacenter_href = @client.clouds(:id => 907).show.datacenters.index.first.show.href
params = {:volume => {:name => 'Client Volume Test', :datacenter_href => datacenter_href, :size => '5'} }
volume = @client.clouds(:id => 907).show.volumes.create(params)
id = volume.show.href.split('/')[-1]

# Destroy
@client.clouds(:id => 907).show.volumes(:id => id).destroy


# ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


#puts "\n\n --Instance Facing Calls --"
@instance_client.api_methods
@instance_client.volumes
@instance_client.volumes.api_methods
@instance_client.volume_snapshots.api_methods
@instance_client.volumes_attachments.api_methods
@instance_client.volumes_types.api_methods
@instance_client.backups(:lineage => 'client_lineage').api_methods
@instance_client.live_tasks(:id => id)

#puts instance_client.get_instance.links
#instance_client.clouds(:id => 716).api_methods
#instance_client.clouds(:id => 716).volumes.first.api_methods
#instance_client.clouds(:id => 716).volume_snapshots.first.api_methods
#instance_client.clouds(:id => 716).volume_types.first.api_methods
#instance_client.clouds(:id => 716).volume_attachments.first.api_methods








