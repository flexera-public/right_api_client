require File.join(File.dirname(__FILE__), 'spec_helper')
require 'irb'

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

  myattachments.each do |attachment|
    begin
      attachment.destroy
    rescue => e
      puts "whoops #{e}"
    end
  end

  # cleanup previous volumes
  #can_find = client.volumes.index(:filter => ["name==#{volname}"]).index
  can_find = client.volumes.index(:filter => ["name==#{volname}"])
  can_find.each do |found|
    begin
    found.destroy
    rescue => e
      puts "whoops #{e}"
    end
  end
end

describe "#HelloSpecWorld" do
  before(:all) do
    @client = example_instance_client
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

    # get the volume_type (CDC only)
    volume_type = @client.volume_types.index.first
    
    # create the volume
    params = {:volume => {:datacenter_href => datacenter_href, :name => @volname, :volume_type_href => volume_type.show.href }}
    new_vol = @client.volumes.create(params)
    new_vol.show.name.should == @volname
    
    # any volumes already attached?
    attached_vols = @client.get_instance.volume_attachments
    # TODO:if so, detach them, destroy them
    # TODO: how do you tell if it's the root volume

    # attach the new volume
    params = {:volume_attachment => {:volume_href => new_vol.show.href, :device => '/dev/sdk', :instance_href => instance.href} }
    new_attachment = @client.volume_attachments.create(params)

    while (new_vol.show.status != "in-use") do
      puts "waiting for volume to attach.. got #{new_vol.show.status}"
      sleep 2
    end

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

    # get the volume_type (CDC only)
    volume_type = @client.volume_types.index.first
    
    # create the volume
    params = {:volume => {:datacenter_href => datacenter_href, :name => @volname, :volume_type_href => volume_type.show.href }}
    new_vol = @client.volumes.create(params)
    new_vol.show.name.should == @volname
    
    # any volumes already attached?
    attached_vols = @client.get_instance.volume_attachments

    # attach the new volume
    params = {:volume_attachment => {:volume_href => new_vol.show.href, :device => '/dev/sdk', :instance_href => instance.href} }
    new_attachment = @client.volume_attachments.create(params)

    while (new_vol.show.status != "in-use") do
      puts "waiting for volume to attach.. got #{new_vol.show.status}"
      sleep 2
    end

    params = {:backup => {:lineage => @volname, :name => @volname, :volume_attachment_hrefs => [new_attachment.show.href]}}
    new_backup = @client.backups.create(params)
  end

  it "short backup" do
    # backup
    params = {:backup => {:lineage => @volname, :name => @volname, :volume_attachment_hrefs => my_volumes(@client).map { |v| v.show.href }}}
    new_backup = @client.backups.create(params)
    # update backup
    new_backup.update(:backup => {:committed => "true"})
    # clean
    @client.backups.cleanup(:keep_last => 1, :lineage => @volname)
  end

  it "should restore" do
    cleanup(@client, @volname)
    backup = @client.backups.index(:lineage => @volname, :filter => [ "latest_before==2011/08/05 00:00:00 +0000", "committed==true", "completed==true"] )
    debugger
    backup.first.show.restore(:instance_href => @client.get_instance.href)
  end

  it "should reset" do
    cleanup(@client, @volname)
  end
end
