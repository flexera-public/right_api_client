require File.join(File.dirname(__FILE__), 'spec_login')


def backup_id
  client.backups.index(:lineage => backup_lineage).first.show.href.split('/')[-1]
end

def backup_lineage
  'client_lineage'
end

def client
  example_instance_client
end

def cloud_id
  907
end


def volume_attachment_id
  client.volume_attachments.index.first.show.href.split('/')[-1]
end

def instance_volume_attachment_id
  client.get_instance.volume_attachments.index.first.show.href.split('/')[-1]
end

def volume_snapshot_id
  client.volume_snapshots.index.first.show.href.split('/')[-1]
end

def volume_volume_snapshot_id
  client.volumes(:id => volume_id).show.volume_snapshots.index.first.show.href.split('/')[-1]
end

def volume_type_id
  client.volume_types.index.first.show.href.split('/')[-1]
end

# Needs to be attached and have a snapshot
def volume_id
  #'2QQBRFJUIUI3M'
  #'AGC6G2PSSUVVD'
  '2QQBRFJUIUI3M'
end









def get_ids(type)
  
  # return the correct things:
  return [client, volume_id] if type == 'volumes'
  return [client, volume_type_id] if type == 'volume_types'
  return [client, volume_snapshot_id, volume_id, volume_volume_snapshot_id] if type == 'volume_snapshots'
  
  return [client, volume_attachment_id, volume_id, instance_volume_attachment_id] if type == 'volume_attachments'
  
  return [client, backup_id, backup_lineage] if type == 'backups'
  return client if type == 'get_instance'
end

