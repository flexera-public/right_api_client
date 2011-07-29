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
b = @yellow_client.backups.create(params)

# Index
@yellow_client.backups
@yellow_client.backups.api_methods
@yellow_client.backups.index(:lineage => "my_lineage")
@yellow_client.backups.index(:lineage => "my_lineage")

# Show
@yellow_client.backups(:id => 'e1a4006c-ad82-11e0-a428-12313b000806')
@yellow_client.backups(:id => 'e1a4006c-ad82-11e0-a428-12313b000806').api_methods
@yellow_client.backups(:id => 'e1a4006c-ad82-11e0-a428-12313b000806').show

# Update
params = {:backup => {:committed => "true"}}
@yellow_client.backups(:id => '3a7be1ca-ad9a-11e0-947f-12313b000806').update(params)

# cleanup
# Note committed need to be true
params = {:keep_last => "1", :lineage => "my_lineage"}
@yellow_client.backups.cleanup(params)

# Destroy
@yellow_client.backups(:id => '3a7be1ca-ad9a-11e0-947f-12313b000806').destroy

# Restore
params = {:instance_href => "/api/clouds/907/instances/26B8QNKI4UOLD"}
task = client.backups(:id => '02175dd2-ad9f-11e0-877a-12313b000806').show.restore(params)



puts "\n\n--Clouds--"
# Index, show
# View the methods avaliable to the root resource clouds:
@yellow_client.clouds
@yellow_client.clouds.api_methods
# Index
@yellow_client.clouds.index
@yellow_client.clouds.index(:filter => ['name==Cloud'])
# Get the cloud resource
@yellow_client.clouds.index(:filter => ['name==Cloud']).first
@yellow_client.clouds(:id => 907)
# View the methods avaliable to this cloud
@yellow_client.clouds(:id => 907).api_methods
# Follow the show
@yellow_client.clouds(:id => 907).show
@yellow_client.clouds(:id => 907).show.api_methods


puts "\n\nDatacenters"
# Index, show
# View the methods avaliable to the root resource datacenters
@yellow_client.clouds(:id => 907).show.datacenters
@yellow_client.clouds(:id => 907).show.datacenters.api_methods
## Index
@yellow_client.clouds(:id => 907).show.datacenters.index
@yellow_client.clouds(:id => 907).show.datacenters.index(:filter => ['name==us-west-1a'])
## Get the datacenter resource
@yellow_client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS')
# View the methods avaliable to this datacenter
@yellow_client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').api_methods
# Follow the show
@yellow_client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show
@yellow_client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.api_methods
# Follow the methods
@yellow_client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.href
@yellow_client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.links
@yellow_client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.cloud.api_methods
@yellow_client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.description
@yellow_client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.name
@yellow_client.clouds(:id => 907).show.datacenters(:id => 'D7TV0QH56MGCS').show.resource_uid


puts "\n\n--Deployments--"
# Index, show, create, update, destroy
# View the methods avaliable to the root resource Deployments
@yellow_client.deployments
@yellow_client.deployments.api_methods
## Index
@yellow_client.deployments.index
@yellow_client.deployments.index(:filter => ['name==ns'])
## Show
@yellow_client.deployments(:id => '66641')
@yellow_client.deployments(:id => '66641').show(:view => 'inputs')
# View the methods avaliable to this deployment
@yellow_client.deployments(:id => '66641').api_methods
# Follow the show
@yellow_client.deployments(:id => '66641').show
@yellow_client.deployments(:id => '66641').show.api_methods
# Follow the methods
@yellow_client.deployments(:id => '66641').show.links
@yellow_client.deployments(:id => '66641').show.servers.api_methods
@yellow_client.deployments(:id => '66641').show.servers.index
@yellow_client.deployments(:id => '66641').show.server_arrays.api_methods
@yellow_client.deployments(:id => '66641').show.inputs.api_methods
@yellow_client.deployments(:id => '66641').show.description
@yellow_client.deployments(:id => '66641').show.name
@yellow_client.deployments(:id => '66641').show.href
# Create a deployment
params = {:deployment => {:name => 'ClientDeployment', :description => 'This is a client test deployment.'}}
deployment = @yellow_client.deployments.create(params)
id = deployment.show.href.split("/")[-1]
@yellow_client.deployments(:id => id).show.name
# Update a deployment
params = {:deployment => {:name => 'MyNewClientDeploymentName', :description => 'This is my updated client test deployment.'}} 
@yellow_client.deployments(:id => id).update(params)
@yellow_client.deployments(:id => id).show.name
# Destroy a deployment
@yellow_client.deployments(:id => id).destroy
# Servers:
@yellow_client.deployments(:id => '66641').show.servers.api_methods
@yellow_client.deployments(:id => '66641').show.servers.index

puts "\n\n--Images--"
# Index, show
# View the methods avaliable to the root resource images
@yellow_client.clouds(:id => 907).show.images.api_methods
## Index
@yellow_client.clouds(:id => 907).show.images.index
@yellow_client.clouds(:id => 907).show.images.index(:filter => ['name==ubuntu'])
@yellow_client.clouds(:id => 907).show.images.index(:filter => ['name==ubuntu']).first.show.href
## Show
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95')
# View the methods avaliable to this datacenter
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').api_methods
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.api_methods
# Follow the methods
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.links
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.cloud.api_methods
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.description
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.visibility
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.virtualization_type
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.os_platform
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.name
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.resource_uid
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.cpu_architecture
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.image_type
@yellow_client.clouds(:id => 907).show.images(:id => 'BI77U68ME5J95').show.href



puts "\n\n--Inputs--"
#Index, multi_update
# View the methods avaliable to the root resource images
# Two ways to do it
@yellow_client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.api_methods
@yellow_client.deployments(:id => 79259).show.inputs.api_methods
## Index
@yellow_client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index
@yellow_client.deployments(:id => 79259).show.inputs.index
@yellow_client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.api_methods
@yellow_client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.links
@yellow_client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.name
@yellow_client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.value
# MultiUpdate
## Two ways to do it
@yellow_client.deployments(:id => 79259).show.inputs.multi_update("inputs[][name]=TEST_NAME&inputs[][value]=text:MyNewValue")
@yellow_client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').inputs.multi_update("inputs[][name]=TEST_NAME&inputs[][value]=text:MyNewValue")
@yellow_client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.name
@yellow_client.clouds(:id => 716).show.instances(:id => 'D9994DAEUVC9').show.inputs.index.first.value


puts "\n\n--InstanceTypes--"
# Index, show
# View the methods avaliable to the root resource instance_types
@yellow_client.clouds(:id => 907).show.instance_types.api_methods
## Index
@yellow_client.clouds(:id => 907).show.instance_types.index
@yellow_client.clouds(:id => 907).show.instance_types.index(:filter => ['name==medium'])
## Show
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1')
# View the methods avaliable to this instance_types
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').api_methods
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.api_methods
# Follow the methods
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.links
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.cloud.api_methods
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.local_disk_size
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.cpu_count
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.local_disks
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.memory
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.resource_uid
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.cpu_architecture
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.cpu_speed
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.description
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.name
@yellow_client.clouds(:id => 907).show.instance_types(:id => '8A98BNJBDGQO1').show.href



puts "\n\n--Instances--"

## Index
@yellow_client.clouds(:id => 907).show.instances
@yellow_client.clouds(:id => 907).show.instances.api_methods
@yellow_client.clouds(:id => 907).show.instances.index
## Show
@yellow_client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV')
@yellow_client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').api_methods
@yellow_client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show
@yellow_client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show(:view => 'full').api_methods

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
task = @yellow_client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.run_executable("right_script_href=/api/right_scripts/371421" +"&inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1")
task.api_methods
task.show.api_methods
# To get updated info need to requery again:
id = task.show.href.split('/')[-1]
task = @yellow_client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.live_tasks(:id => id)
task.show.summary
#
#puts "--MultiRunExecutable--"
task = @yellow_client.clouds(:id => 907).show.instances.index(:filter => ['name==ns_server5']).multi_run_executable("right_script_href=/api/right_scripts/371421" +"&inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1")
task.api_methods
task.show.api_methods

#puts "--Reboot--"
@yellow_client.clouds(:id => 907).show.instances(:id => 'A1BQRR03KDV').show.reboot

#puts "--Launch--"
## Multiple inputs are a bit tricky to define and have to be in this format:
inputs = "inputs[][name]=TEST_NAME&inputs[][value]=text:MyValue&inputs[][name]=rs_utils/timezone&inputs[][value]=text:GMT"
server = @yellow_client.clouds(:id => 907).show.instances(:id => '9O2GFF4A43CPT').show.launch(inputs)

#puts "--Update--"
params = {:instance => {:datacenter_href => @yellow_client.clouds(:id => 907).show.datacenters.index(:filter => ['name==us-west-1b']).first.show.href}}
@yellow_client.clouds(:id => 907).show.instances(:id => '9O2GFF4A43CPT').update(params)

#puts "--MultiTerminate--"
task = @yellow_client.clouds(:id => 907).show.instances.multi_terminate(:filter => ['name==ns_server4'])
task.api_methods
task.show.api_methods

# Terminate
@yellow_client.clouds(:id => 907).show.instances(:id => '9O2GFF4A43CPT').show.terminate
#The instance.terminated_at value is available in the extended or full view, but you have to filter and search for your instance first.
@yellow_client.clouds(:id => 716).show(:view => 'extended', :filter => ['state==inactive', 'resource_uid==7I0K1GBTJ2I2T']).terminated_at

# reboot
@yellow_client.clouds(:id => 907).show.instances(:id => '6TJPO0I5C716C').show.reboot




puts "\n\n--MonitoringMetics--"
# Index, show, data
# View the methods avaliable to the root resource instance_types
@yellow_client.clouds(:id => 907).show.instances(:id => 'ES29I0BO32AJ1').show.monitoring_metrics
## Index
@yellow_client.clouds(:id => 907).show.instances(:id => 'ES29I0BO32AJ1').show.monitoring_metrics.api_methods
@yellow_client.clouds(:id => 907).show.instances(:id => 'ES29I0BO32AJ1').show.monitoring_metrics.index
## Show
@yellow_client.clouds(:id => 232).show.instances(:id => '5Q1V4V35A2C5K').show.monitoring_metrics.index.last.show.href
# data
@yellow_client.clouds(:id => 232).show.instances(:id => '5Q1V4V35A2C5K').show.monitoring_metrics(:id => 'dsfdsf').show.data
@yellow_client.clouds(:id => 232).show.instances(:id => '5Q1V4V35A2C5K').show.monitoring_metrics(:id => 'dsfdsf').show.data.api_methods
@yellow_client.clouds(:id => 232).show.instances(:id => '5Q1V4V35A2C5K').show.monitoring_metrics(:id => 'dsfdsf').show.data.href

#"--MultiCloudImageSettings--"
# Index, show
# Index
@local_client.multi_cloud_images.index.first.show.settings
@local_client.multi_cloud_images(:id => 52426).show.settings.api_methods
@local_client.multi_cloud_images(:id => 52426).show.settings.index
# Show
@local_client.multi_cloud_images(:id => 52426).show.settings(:id => 120991)
@local_client.multi_cloud_images(:id => 52426).show.settings(:id => 120991).api_methods
@local_client.multi_cloud_images(:id => 52426).show.settings(:id => 120991).show
@local_client.multi_cloud_images(:id => 52426).show.settings(:id => 120991).show.api_methods

# --MultiCloudImages
# Index, show
# Index
@local_client.multi_cloud_images
@local_client.multi_cloud_images.api_methods
@local_client.multi_cloud_images.index
# Show
@local_client.multi_cloud_images(:id => 52426)
@local_client.multi_cloud_images(:id => 52426).api_methods
@local_client.multi_cloud_images(:id => 52426).show
@local_client.multi_cloud_images(:id => 52426).show.api_methods
#:links, :settings, :revision, :description, :name, :href



# "--SecurityGroups--"
## Index
@local_client.clouds(:id => 907).show.security_groups
@local_client.clouds(:id => 907).show.security_groups.api_methods
@local_client.clouds(:id => 907).show.security_groups.index
## Show
@local_client.clouds(:id => 907).show.security_groups(:id => 'CCCFLO89QS4QQ')
@local_client.clouds(:id => 907).show.security_groups(:id => 'CCCFLO89QS4QQ').api_methods
@local_client.clouds(:id => 907).show.security_groups(:id => 'CCCFLO89QS4QQ').show
@local_client.clouds(:id => 907).show.security_groups(:id => 'CCCFLO89QS4QQ').show.api_methods
@local_client.clouds(:id => 907).show.security_groups(:id => 'CCCFLO89QS4QQ').show(:view => 'tiny').api_methods
#:links, :cloud, :name, :resource_uid, :href



#puts "\n\n--ServerArrays--"
## Index  (two ways to do it)
@yellow_client.server_arrays
@yellow_client.server_arrays.api_methods
@yellow_client.server_arrays.index

@yellow_client.deployments(:id => '89065').show.server_arrays
@yellow_client.deployments(:id => '89065').show.server_arrays.api_methods
@yellow_client.deployments(:id => '89065').show.server_arrays.index
## Show
@yellow_client.server_arrays(:id => '13356')
@yellow_client.server_arrays(:id => '13356').api_methods
@yellow_client.server_arrays(:id => '13356').show
@yellow_client.server_arrays(:id => '13356').show.api_methods

@yellow_client.deployments(:id => '89065').show.server_arrays(:id => 13356)
@yellow_client.deployments(:id => '89065').show.server_arrays(:id => 13356).api_methods
@yellow_client.deployments(:id => '89065').show.server_arrays(:id => 13356).show


#puts "--Create--"
server_template_href = @yellow_client.server_templates.index(:filter => ['name==Base ServerTemplate All Clouds - QA']).first.show.href
cloud_href = @yellow_client.clouds(:id => 907).show.href
deployment_href = @yellow_client.deployments(:id => 89065).show.href
security_group_hrefs = [@yellow_client.clouds(:id => 907).show.security_groups.index(:filter => ['name==default']).first.show.href]
datacenter_href = @yellow_client.clouds(:id => 907).show.datacenters.index.first.show.href
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

new_server_array = @yellow_client.server_arrays.create(params)
new_server_array.api_methods
#
# You can also create server_array from a specific deployment, where :deployment_href param isn't needed
new_server_array = @yellow_client.deployments(:id => 89065).show.server_arrays.create(params)
new_server_array.api_methods

id = new_server_array.show.href.split('/')[-1]
#puts "--Launch--"
## Inputs are a bit tricky so they have to be set in a long string in the this format.
inputs = "inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1&inputs[][name]=rs_utils/timezone&inputs[][value]=text:GMT"
@yellow_client.server_arrays(:id => id).show.launch(inputs)
#
#puts "--Update--"
params = {
  :server_array => { 
    :name => 'MyUltraNewServerArrayName'
  }
}
@yellow_client.server_arrays(:id => id).update(params)
# or
@yellow_client.deployments(:id => '89065').show.server_arrays(:id => id).update(params)

#puts "--MultiRunExecutable--"
task = client.server_arrays(:id => id).multi_run_executable("right_script_href=/api/right_scripts/371421" +"&inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1")
task.api_methods
task.api_methods.show.api_methods

#
#puts "--MultiTerminate--"
task = @yellow_client.server_arrays(:id => id).multi_terminate
task.api_methods
task.api_methods.show.api_methods

#
# Destroy (two ways to do it)
@yellow_client.server_arrays(:id => id).destroy
@yellow_client.deployments(:id => 89065).show.server_arrays(:id => id).destroy



# ServerTemplates
#Index
@local_client.server_templates
@local_client.server_templates.api_methods
@local_client.server_templates.index
#Show
@local_client.server_templates(:id => 2)
@local_client.server_templates(:id => 2).api_methods
@local_client.server_templates(:id => 2).show
@local_client.server_templates(:id => 2).show.api_methods



#puts "\n\n--Servers--"
# Index (two ways to do it)
@yellow_client.servers
@yellow_client.servers.api_methods
@yellow_client.servers.index

@yellow_client.deployments(:id => '89065').show.servers
@yellow_client.deployments(:id => '89065').show.servers.api_methods
@yellow_client.deployments(:id => '89065').show.servers.index

## Show (two ways to do it) 
@yellow_client.servers(:id => 967094)
@yellow_client.servers(:id => 967094).api_methods
@yellow_client.servers(:id => 967094).show
@yellow_client.servers(:id => 967094).show.api_methods

@yellow_client.deployments(:id => '89065').show.servers(:id => '967094')
@yellow_client.deployments(:id => '89065').show.servers(:id => '967094').api_methods
@yellow_client.deployments(:id => '89065').show.servers(:id => '967094').show(:view => 'instance_detail')
@yellow_client.deployments(:id => '89065').show.servers(:id => '967094').show(:view => 'instance_detail').api_methods

#puts "--Create--"
server_template_href = @yellow_client.server_templates.index(:filter => ['name==Base ServerTemplate All Clouds - QA']).first.show.href
cloud_href = @yellow_client.clouds(:id => 907).show.href
deployment_href = @yellow_client.deployments(:id => 89065).show.href
security_group_hrefs = [@yellow_client.clouds(:id => 907).show.security_groups.index(:filter => ['name==default']).first.show.href]
datacenter_href = @yellow_client.clouds(:id => 907).show.datacenters.index.first.show.href

params = { :server => {:name => 'The Ultra Client Server Test', :deployment_href => deployment_href, :instance => {:server_template_href => server_template_href, :cloud_href => cloud_href, :security_group_hrefs => security_group_hrefs, :datacenter_href => datacenter_href}}}
new_server = @yellow_client.servers.create(params)
new_server.api_methods
## You can also create server from a specific deployment, where :deployment_href param isn't needed
new_server = @yellow_client.deployments(:id => 89065).show.servers.create(params)
new_server.api_methods

id = new_server.show.href.split('/')[-1]
#puts "--Launch--"
## Inputs are a bit tricky so they have to be set in a long string in the this format.
inputs = "inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1&inputs[][name]=rs_utils/timezone&inputs[][value]=text:GMT"
@yellow_client.servers.index(:filter => ['name==The Ultra Client Server Test']).first.show.launch(inputs)
#
#puts "--Update--"
params = {:server => {:name => 'NewServerName'}}
@yellow_client.servers(:id => id).update(params)

# Destroy (two ways to do it)
@yellow_client.servers(:id => id).destroy
@yellow_client.deployments(:id => 89065).show.servers(:id => id).destroy

#Terminate
@yellow_client.servers(:id => 967079).show.terminate



#"--SshKeys--"
# Index, show, create, destroy
## Index
@local_client.clouds(:id => 907).show.ssh_keys
@local_client.clouds(:id => 907).show.ssh_keys.api_methods
@local_client.clouds(:id => 907).show.ssh_keys.index
# Create
params = {:ssh_key => {:name => 'MySshKey'}}
resource = @local_client.clouds(:id => 907).show.ssh_keys.create(params)
id = resource.show.href.split('/')[-1]
## Show
@local_client.clouds(:id => 907).show.ssh_keys(:id => id)
@local_client.clouds(:id => 907).show.ssh_keys(:id => id).api_methods
@local_client.clouds(:id => 907).show.ssh_keys(:id => id).show
@local_client.clouds(:id => 907).show.ssh_keys(:id => id).show.api_methods
# :links, :cloud, :resource_uid, :href
# Destroy
@local_client.clouds(:id => 907).show.ssh_keys(:id => id).destroy





#"--Tags--"
@yellow_client.tags.api_methods
# by_resource
@yellow_client.tags.by_resource(:resource_hrefs => ['/api/servers/967094', '/api/servers/967078'])
@yellow_client.tags.by_resource(:resource_hrefs => ['/api/servers/967094']).first.api_methods
@yellow_client.tags.by_resource(:resource_hrefs => ['/api/servers/967094']).first.resource.api_methods
# by_tag
@yellow_client.tags.by_tag(:resource_type => 'servers', :tags => ['ns_tag']).first
@yellow_client.tags.by_tag(:resource_type => 'servers', :tags => ['ns_tag']).first.api_methods
@yellow_client.tags.by_tag(:resource_type => 'servers', :tags => ['ns_tag']).first.resource.first.api_methods
#multi_add
@yellow_client.tags.multi_add(:resource_hrefs => ['/api/servers/967078'], :tags => ['client_tag'])
#multi_delete
@yellow_client.tags.multi_delete(:resource_hrefs => ['/api/servers/967098'], :tags => ['client_tag'])


# Volume_attachments

# Volume_snapshots

# Volume_types

# Volumes




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








