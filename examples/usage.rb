# This file provides a long list of examples that demonstrate how the
# Right API Client can be used. Un-comment the section you want to try...

require File.expand_path(File.dirname(__FILE__) + '/../lib/right_api_client')
require 'yaml'

# Read username, password and account_id from file, or you can just pass them
# as arguments when creating a new client.
args = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/login.yml'))

puts "Creating RightScale API Client and logging in..."
# Account ID is available from the browser address bar on this page: dashboard > Settings > Account Settings
client = RightApiClient.new(args[:email], args[:password], args[:account_id])
#puts 'Available methods:', client.api_methods
# Can also specify api_url and api_version, which is useful for testing, e.g.:
#client = RightApiClient.new(args[:email], args[:password], args[:account_id], 'https://test.rightscale.com', '2.0')


# The HTTP calls made by RightApiClient can be logged in two ways:
# Log to a file
#client.log('C:\Users\Ali\Desktop\log.txt')
# Log to SDTOUT, which is usually the screen
#require 'logger'
#client.log(Logger.new(STDOUT))


puts "\n\n--Session--"
# Creating a new client automatically creates a session and logs in.
puts client.session.message

puts "\n\n--Clouds--"
# Index
p client.clouds
# Show
resource = client.clouds(:id => 907)
puts 'Available methods:', resource.api_methods


#puts "\n\nDatacenters"
## Index
#p client.clouds(:id => 907).datacenters
## Show
#resource = client.clouds(:id => '907').datacenters(:id => 'D7TV0QH56MGCS')
#puts 'Available methods:', resource.api_methods


#puts "\n\n--Deployments--"
## Index
#p client.deployments
## Show
#resource = client.deployments(:id => 79259)
#puts 'Available methods:', resource.api_methods
#
#puts "--Create--"
#params = {:deployment => {
#  :name => 'MyDeployment',
#  :description => 'This is my deployment.'
#}}
#resource = client.deployments.create(params)
#p resource
#
#params = {:deployment => {
#  :naame => 'MyNewDeploymentName',
#  :description => 'This is my updated deployment.'
#}} 
#client.deployments(:id => 80890).update(params)
#
#client.deployments(:id => 80722).destroy


#puts "\n\n--Images--"
## Index
#p client.clouds(:id => 716).images
## Show
#resource = client.clouds(:id => 716).images(:id => 'DABTF58P0BPO2')
#puts 'Available methods:', resource.api_methods


#puts "\n\n--Inputs--"
## Index (two ways to do it)
#p client.clouds(:id => 716).instances(:id => '558HE0C46MO2D').inputs
#p client.deployments(:id => 79259).inputs
#puts client.deployments(:id => 79259).inputs[0].name # or .value
#
#puts "--MultiUpdate--"
## Two ways to do it
#client.deployments(:id => 79259).inputs.multi_update("inputs[][name]=TEST_NAME&inputs[][value]=text:MyNewValue")
#client.clouds(:id => 716).instances(:id => 'DV47B01F0PTUC').inputs.multi_update("inputs[][name]=TEST_NAME&inputs[][value]=text:MyNewValue")


#puts "\n\n--InstanceTypes--"
## Index
#p client.clouds(:id => 716).instance_types
## Show
#resource = client.clouds(:id => 716).instance_types(:id => '3NBQD7AT9G3NH')
#puts 'Available methods:', resource.api_methods


#puts "\n\n--Instances--"
## Index
##puts client.clouds(:id => 716).instances
## Show
#resource = client.clouds(:id => 716).instances(:id => '2UADFPM10N93P')
#puts 'Available methods:', resource.api_methods
#
##puts "--RunExecutable--"
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
#task = client.clouds(:id => 716).instances(:id => '8BRIGRL7TM00T').run_executable(
#  "right_script_href=https://my.rightscale.com/api/right_scripts/296533" +
#  "&inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1")
#puts task.api_methods
#
#puts "--MultiRunExecutable--"
#task = client.clouds(:id => 716).instances(:filters => ['name==S1']).multi_run_executable(
#  "right_script_href=https://my.rightscale.com/api/right_scripts/296533" +
#  "&inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1")
#puts task.api_methods
#
#puts "--Launch--"
## Multiple inputs are a bit tricky to define and have to be in this format:
#inputs = "inputs[][name]=TEST_NAME&inputs[][value]=text:MyValue&inputs[][name]=rs_utils/timezone&inputs[][value]=text:GMT"
#p client.clouds(:id => 716).instances(:id => '2UADFPM10N93P').launch(inputs)
#
#puts "--Update--"
#params = {
#  :instance => { 
#    :instance_type_href => client.clouds(:id => 716).instance_types(:filters => ['name==Small Direct']).first.href
#  }
#}
#client.clouds(:id => 716).instances(:id => '2UADFPM10N93P').update(params)
#
#puts "--MultiTerminate--"
#task = client.clouds(:id => 716).instances(:filters => ['name==S1']).multi_terminate
#puts task.api_methods
#
# Can't do the following as the API doesn't support them, but instance.links has the info.
#p resource.server_template
#p resource.multi_cloud_image
#
#instance = client.clouds(:id => 716).instances(:id => '7I0K1GBTJ2I2T')
#instance.terminate
#The instance.terminated_at value is available in the extended or full view, but you have to filter and search for your instance first.
#puts client.clouds(:id => 716, :view => 'extended', :filters => ['state==inactive', 'resource_uid==7I0K1GBTJ2I2T']).terminated_at


#puts "\n\n--MonitoringMetics--"
## Index
#p client.clouds(:id => 716).instances(:id => '6FDOUES5Q7ECE').monitoring_metrics
## Show
#resource = client.clouds(:id => 716).instances(:id => '6FDOUES5Q7ECE').monitoring_metrics(:id => 'cpu-0:cpu_overview')
#puts 'Available methods:', resource.api_methods


#puts "\n\n--SecurityGroups--"
## Index
#p client.clouds(:id => 716).security_groups
## Show
#resource = client.clouds(:id => 716).security_groups(:id => 'FSGQ126DPS7GU')
#puts 'Available methods:', resource.api_methods, true


#puts "\n\n--ServerArrays--"
## Index  (two ways to do it)
#p client.server_arrays
#p client.deployments(:id => '79259').server_arrays
## Show
#resource = client.server_arrays(:id => '12038')
#puts 'Available methods:', resource.api_methods
##
## Can't do the following as the API doesn't support it due to a bug, but resource.links has the info.
#p resource.current_instances
##
# 
#puts "--Create--"
## You can't yet access server templates or MCIs from the API,
## so you need to copy the server template ID out of your browser...
#server_template_href = "/api/server_templates/65866"
#cloud_com = client.clouds(:id => 716)
#params = { :server_array => {
#  :array_type => 'alert',
#  :deployment_href => client.deployments(:filters => ['name==MyDeployment']).first.href,
#  :name => 'MyServerArray',
#  :description => 'This is my server array.',
#  :state => 'disabled',
#  :elasticity_params => {
#    :alert_specific_params => {
#      :decision_threshold => 51
#    },
#    :bounds => {
#      :max_count => 3,
#      :min_count => 1
#    },
#    :pacing => {
#      :resize_calm_time => 5,
#      :resize_down_by => 1,
#      :resize_up_by => 1
#    }
#  },
#  :instance => {
#    :server_template_href => server_template_href,
#    :cloud_href => cloud_com.href,
#    :security_group_hrefs => [cloud_com.security_groups(:filters => ['name==default']).first.href],
#    :datacenter_href => cloud_com.datacenters.first.href
#  }  
#}}
#new_server_array = client.server_arrays.create(params)
#p new_server_array
#
# You can also create server_array from a specefic deployment, where :deployment_href param isn't needed
#new_server_array = client.deployments(:id => 79259).server_arrays.create(params)
#p new_server_array
#
#puts "--Launch--"
## Inputs are a bit tricky so they have to be set in a long string in the this format.
#inputs = "inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1&inputs[][name]=rs_utils/timezone&inputs[][value]=text:GMT"
#p client.server_arrays(:filters => ['name==array007']).first.launch(inputs)
#
#puts "--Update--"
#params = {
#  :server_array => { 
#    :name => 'MyNewServerArrayName'
#  }
#}
#client.server_arrays(:id => 12093).update(params)
#
#puts "--MultiRunExecutable--"
#task = client.server_arrays(:id => 12038).multi_run_executable(
#  "right_script_href=https://my.rightscale.com/api/right_scripts/296533" + 
#  "&inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1")
#puts task.api_methods
#
#puts "--MultiTerminate--"
#task = client.server_arrays(:id => 12038).multi_terminate
#puts task.api_methods
#
# Destroy (two ways to do it)
#client.server_arrays(:id => 12038).destroy
#client.deployments(:id => 79259).server_arrays(:id => 12066).destroy


#puts "\n\n--Servers--"
# Index (two ways to do it)
#p client.servers[0]
#p client.deployments(:id => '79259').servers
## Show (two ways to do it) 
##p client.deployments(:id => '79259').servers(:id => '927690')
#resource = client.servers(:id => '927690')
#puts 'Available methods:', resource.api_methods
##
# 
#puts "--Create--"
# You can't yet access server templates or MCIs from the API,
# so you need to copy the server template ID out of your browser.
#server_template_href = "/api/server_templates/65866"
#cloud_com = client.clouds(:id => 716)
#params = { :server => {
#  :name => 'S1',
#  :deployment_href => client.deployments(:filters => ['name==MyDeployment']).first.href,
#  :instance => {
#    :server_template_href => server_template_href,
#    :cloud_href => cloud_com.href,
#    :security_group_hrefs => [cloud_com.security_groups(:filters => ['name==default']).first.href],
#    :datacenter_href => cloud_com.datacenters.first.href
#  }
#}}
#new_server = client.servers.create(params)
#p new_server
## You can also create server from a specefic deployment, where :deployment_href param isn't needed
##new_server = client.deployments(:id => 79259).servers.create(params)
##p new_server
#
#puts "--Launch--"
## Inputs are a bit tricky so they have to be set in a long string in the this format.
#inputs = "inputs[][name]=TEST_NAME&inputs[][value]=text:VAL1&inputs[][name]=rs_utils/timezone&inputs[][value]=text:GMT"
#p client.servers(:filters => ['name==S1']).first.launch(inputs)
#
#puts "--Update--"
#params = {
#  :server => { 
#    :name => 'NewServerName'
#  }
#}
#client.servers(:id => 928822).update(params)
#
# Destroy (two ways to do it)
#client.servers(:id => 927690).destroy
#client.deployments(:id => 79259).servers(:id => 927365).destroy


#puts "\n\n--SshKeys--"
## Index
#p client.clouds(:id => 907).ssh_keys
## Show
#resource = client.clouds(:id => 907).ssh_keys(:id => 'BT3T0AN8DUTVN')
#puts 'Available methods:', resource.api_methods
#
#puts "--Create--"
#params = {:ssh_key => {
#  :name => 'MySshKey'
#}}
#resource = client.clouds(:id => 907).ssh_keys.create(params)
#p resource
#
#client.clouds(:id => 907).ssh_keys(:id => '9KJ7176J0UM8T').destroy


#puts "\n\n--Tasks--"
## Show
#resource = client.clouds(:id => 716).instances(:id => '6B2I3GAKGG57V').live_tasks(:id => 'ae-55973312')
#puts 'Available methods:', resource.api_methods
