require File.join(File.dirname(__FILE__), 'spec_helper')
require 'irb'
require '/var/spool/cloud/user-data'

def my_volumes(client)
  instance = client.get_instance
  # cleanup previous attachments
  va = client.volume_attachments.index
  myattachments = [] 
  va.each do |a|
    link = a.show.links.detect { |l| l['rel'] == 'instance' }
    myattachments << a if link['href'] == instance.href && !a.show.device.include?('unknown')
  end
  myattachments
end

def cleanup(client, volname)
  myattachments = my_volumes(client) 
  delete_these = []

  myattachments.each do |attachment|
    delete_these << attachment.show.volume
    attachment.destroy
  end
  delete_these.each do |volume|
    volume.destroy
  end

end

def generate_physical_device_names(count)
  x = IO.read("/proc/partitions")

  if x =~ / vda/
    devstr = "vd"
    # we're in CDC/kvm?
  elsif x =~ / sda/
    devstr = "sd"
    # we're in euca/kvm
  elsif x =~ / xvda/
    devstr = "xvd"
    # we're in xen
  end

  lines = x.split("\n")
  lines.last =~ /#{devstr}([a-z]+)[0-9]*$/
  last_dev_letter = $1

  new_dev_list = []
  devrange = (last_dev_letter .. 'z').to_a

  count.to_i.times do |device_gen|
    new_dev_list << "/dev/#{devstr}#{devrange[device_gen+1]}"
  end

  new_dev_list
end

def is_cdc?
  return true if IO.read('/etc/rightscale.d/cloud').chomp =~ /cloud\.com|vmops/
  return false
end

describe "#HelloSpecWorld" do
  before(:all) do
    account_id, token = ENV['RS_API_TOKEN'].split(/:/)
    @client = RightApi::Client.new(:instance_token => token, :account_id => account_id)
    @client.log(STDOUT)
    @volname = "spec_test_five_billion"
    @cloud_id = 1723

    @client.headers[:cookies].should_not be_nil
  end

  it "should create from scratch" do
    cleanup(@client, @volname)
    # get the instance info

    instance = @client.get_instance
    datacenter_link = instance.links.detect { |i| i["rel"] == "datacenter" }
    datacenter_href = datacenter_link["href"]

    # create the volume
    params = {:volume => {:datacenter_href => datacenter_href, :name => @volname}}

    if is_cdc?
      # get the volume_type (CDC only)
      params[:volume][:volume_type_href] = @client.volume_types.index.first.show.href
    else
      params[:volume][:size] = '1'
    end

    new_vol = @client.volumes.create(params)
    new_vol.show.name.should == @volname

    puts 'waiting for volume to create'
    while (new_vol.show.status != 'available')
      sleep 2
    end
    
    # any volumes already attached?
    attached_vols = @client.get_instance.volume_attachments
    # TODO:if so, detach them, destroy them
    # TODO: how do you tell if it's the root volume

    # attach the new volume
    device_name = generate_physical_device_names(1).first
    params = {:volume_attachment => {:volume_href => new_vol.show.href, :device => device_name, :instance_href => instance.href} }
    new_attachment = @client.volume_attachments.create(params)

    while (new_vol.show.status != "in-use") do
      puts "waiting for volume to attach.. got #{new_vol.show.status}"
      sleep 2
    end

    new_attachment.show.device.should == device_name

    attached_vols = my_volumes(@client)
    attached_vols.size.should == 2

    new_attachment.destroy

    attached_vols = my_volumes(@client)
    attached_vols.size.should == 1

    #destroy
    new_vol.destroy
    can_find = @client.volumes.index(:filter => ["name==#{@volname}"])
    can_find.should == []
  end

  it "should backup" do
    cleanup(@client, @volname)

    instance = @client.get_instance
    datacenter_link = instance.links.detect { |i| i["rel"] == "datacenter" }
    datacenter_href = datacenter_link["href"]

    # create the volume
    params = {:volume => {:datacenter_href => datacenter_href, :name => @volname}}

    if is_cdc?
      # get the volume_type (CDC only)
      params[:volume][:volume_type_href] = @client.volume_types.index.first.show.href
    else
      params[:volume][:size] = '1'
    end

    params[:volume_type_href] = @client.volume_types.index.first.show.href if is_cdc?

    new_vol = @client.volumes.create(params)
    new_vol.show.name.should == @volname

    puts 'waiting for volume to create'
    while (new_vol.show.status != 'available')
      sleep 2
    end
    
    # any volumes already attached?
    attached_vols = @client.get_instance.volume_attachments

    # attach the new volume
    params = {:volume_attachment => {:volume_href => new_vol.show.href, :device => generate_physical_device_names(1).first, :instance_href => instance.href} }
    new_attachment = @client.volume_attachments.create(params)

    while (new_vol.show.status != "in-use") do
      puts "waiting for volume to attach.. got #{new_vol.show.status}"
      sleep 2
    end

    params = {:backup => {:lineage => @volname, :name => @volname, :volume_attachment_hrefs => [new_attachment.show.href]}}
    new_backup = @client.backups.create(params)
    new_backup.update(:backup => {:committed => "true"})
    # clean
    @client.backups.cleanup(:keep_last => 1, :lineage => @volname)
  end

  it "should restore" do
    cleanup(@client, @volname)
    backup = @client.backups.index(:lineage => @volname, :filter => [ "latest_before==2011/08/05 00:00:00 +0000", "committed==true", "completed==true"] )
    backup.first.should_not be_nil
    backup.first.show.restore(:instance_href => @client.get_instance.href)
  end

  it "should reset" do
    cleanup(@client, @volname)
  end
end
