require File.expand_path("../lib/right_api_client")
require 'yaml'

# Example of how to create a server in a deployment
# based on an existing server template.
#
# You can't yet access server templates or MCIs from the API,
# so this is a little silly, as you need to copy the server template
# ID out of your browser...
#
config_file = File.expand_path("~/.rightscale/right_api_client.yml")
args = YAML.load_file(config_file)
user, password, account = args[:user], args[:password], args[:account]

client = RightApiClient.new(user, password, account)
deployment = client.deployments(:filters => ['name==Dane Multicloud']).first
rackspace, cloud_com  = client.clouds # no special magic here, just that 2 clouds are returned in this order

server_template_href = "/api/server_templates/65866"
security_group_href  = cloud_com.security_groups.first.href
datacenter_href      = cloud_com.datacenters.first.href

p deployment.servers 

rackspace_server = deployment.create_server(
  :name => "My Rackspace Server",
  :deployment_href => deployment.href,
  :instance => {
    :server_template_href => server_template_href,
    :cloud_href => rackspace.href
  }
)
p rackspace_server

cloud_com_server = deployment.create_server(
  :name => "My Cloud.com Server",
  :deployment_href => deployment.href,
  :instance => {
    :server_template_href => server_template_href,
    :cloud_href => cloud_com.href,
    :security_group_hrefs => [security_group_href],
    :datacenter_href => datacenter_href
  }
)
p cloud_com_server



servers = deployment.servers

p servers


deployment.servers.each { |s| s.launch }
deployment.servers.each { |s| s.terminate }

#pp server.current_instance.run_executable("right_script_href" => "https://my.rightscale.com/api/right_scripts/186354")
#pp server.next_instance.raw

#if server.state == "inactive"
#  p server.launch
#else
#  p [:state, server.state]
#end