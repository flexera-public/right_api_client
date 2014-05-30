#!/usr/bin/env ruby
require File.expand_path('../../lib/right_api_client', __FILE__)
require 'yaml'
require 'pry'

begin
  @client = RightApi::Client.new(YAML.load_file(File.expand_path('../../config/login.yml', __FILE__)))
end

# Pass in the name of the server
server_name = ARGV[0]



server = @client.servers.index(:filter => ["name==#{server_name}"])
instance = server.first.current_instance
attachments = instance.show.volume_attachments.index

attachments.reject! do |a|
  a.resource_uid =~ /boot/
end
@snapshots = nil
attachments.each do |attachment|
  volume = attachment.volume.show
  puts "Volume #{volume.name} found with status #{volume.status}"

  snapshots = volume.volume_snapshots.index
  @snapshots = snapshots
  if snapshots.empty?
    puts "No snapshots to clean up were found"
    next 
  end

  snapshots.index.each do |snapshot|
    if snapshot == nil
      next
    end
    if snapshot.state =~ /available/
      puts "Found snapshot with state #{snapshot.state}"
    end
    puts " == Listing tags for snapshot == "
    snap_href = snapshot.href
    snap_tags = @client.tags.by_resource(:resource_hrefs => [snap_href])
    snap_tags.each do |t|
      puts t.show.tags
    end
  end
end

# Uncomment next line to drop into pry and inspect objects
#pry
