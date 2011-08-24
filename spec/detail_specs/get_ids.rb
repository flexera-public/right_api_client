# Note: Before running the detailed specs, these ids need to be checked to make sure they are valid
#  If time: create mocked data similar to API.
#  This was just a sanity check to make sure that most calls worked

require File.join(File.dirname(__FILE__), 'spec_login')

def backup_id
  client.backups.index(:lineage => backup_lineage).first.show.href.split('/')[-1]
end

# Needs to exist
def backup_lineage
  'client_lineage'
end

def client
  example_client
end

def cloud_id
  907
end

def datacenter_id
  client.clouds(:id => cloud_id).show.datacenters.index.first.show.href.split('/')[-1]
end

def deployment_id
  client.deployments.index.first.show.href.split('/')[-1]
end

def image_id
  client.clouds(:id => cloud_id).show.images.index.first.show.href.split('/')[-1]
end

# Needs to be an instance with inputs
def input_instance_id
  client.clouds(:id => cloud_id).show.instances.index[1].show.href.split('/')[-1]
end

# Needs to be a deployment with inputs
def input_deployment_id
  return 79259
end

# This instance needs to have a volume attached to it
def instance_id
  'A1BQRR03KDV'
end

def instance_type_id
  client.clouds(:id => cloud_id).show.instance_types.index.first.show.href.split('/')[-1]
end

def monitoring_metric_instance_id
end

def multi_cloud_image_setting_id
  client.multi_cloud_images(:id => multi_cloud_image_id).show.settings.index.first.show.href.split('/')[-1]
end

# A multi_cloud_image with settings
def multi_cloud_image_id
  52426
end

def mci_server_template_id
  server_template_id
end

def mci_server_template_mci_id
  client.server_templates(:id => server_template_id).show.multi_cloud_images.index.first.show.href.split('/')[-1]
end


def security_group_id
  client.clouds(:id => cloud_id).show.security_groups.index.first.show.href.split('/')[-1]
end


def server_array_id
  client.server_arrays.index.first.show.href.split('/')[-1]
end

def server_template_id
  client.server_templates.index.first.show.href.split('/')[-1]
end

# This server should be terminated
def server_id
  client.servers.index.first.show.href.split('/')[-1]
end

def deployment_server_id
  client.deployments(:id => deployment_id).show.servers.index.first.show.href.split('/')[-1]
end

def ssh_key_id
  client.clouds(:id => cloud_id).show.ssh_keys.index.first.show.href.split('/')[-1]
end

# Need to be servers
def resource_hrefs
  ['/api/servers/967094', '/api/servers/967078']
end

# Assumes that this tag is on at least two different servers
def tags
  ['ns_tag']
end

def volume_attachment_id
  client.clouds(:id => cloud_id).show.volume_attachments.index.first.show.href.split('/')[-1]
end

def instance_volume_attachment_id
  client.clouds(:id => cloud_id).show.instances(:id => instance_id).show.volume_attachments.index.first.show.href.split('/')[-1]
end

def volume_snapshot_id
  client.clouds(:id => cloud_id).show.volume_snapshots.index.first.show.href.split('/')[-1]
end

def volume_volume_snapshot_id
  client.clouds(:id => cloud_id).show.volumes(:id => volume_id).show.volume_snapshots.index.first.show.href.split('/')[-1]
end

def volume_type_id
  client.clouds(:id => 716).show.volume_types.index.first.show.href.split('/')[-1]
end

# The Volume needs to be attached and have a snapshot
def volume_id
  '2QQBRFJUIUI3M'
end









def get_ids(type)

  # return the correct things:
  return [client, cloud_id] if type == 'clouds'
  return [client, cloud_id, datacenter_id] if type == 'datacenters'
  return [client, cloud_id, image_id] if type == 'images'
  return [client, cloud_id, input_instance_id, input_deployment_id] if type == 'inputs'
  return [client, cloud_id, instance_type_id] if type == 'instance_types'
  return [client, multi_cloud_image_id, multi_cloud_image_setting_id] if type == 'multi_cloud_image_settings'
  return [client, mci_server_template_id, mci_server_template_mci_id, multi_cloud_image_id] if type == 'multi_cloud_images'
  return [client, cloud_id, security_group_id] if type == 'security_groups'
  return [client, server_template_id] if type == 'server_templates'
  return [client, cloud_id, ssh_key_id] if type == 'ssh_keys'
  return [client, cloud_id, volume_id] if type == 'volumes'
  return [client, volume_type_id] if type == 'volume_types'
  return [client, cloud_id, volume_snapshot_id, volume_id, volume_volume_snapshot_id] if type == 'volume_snapshots'

  return [client, cloud_id, volume_attachment_id, volume_id, instance_id, instance_volume_attachment_id] if type == 'volume_attachments'
  return [client, deployment_id] if type == 'deployments'
  return [client, server_id, deployment_id, deployment_server_id] if type == 'servers'
  return [client, resource_hrefs, tags] if type == 'tags'
  return [client, backup_id, backup_lineage] if type == 'backups'
  return [client, server_array_id] if type == 'server_arrays'
  return [client, cloud_id, instance_id] if type == 'instances'
end

