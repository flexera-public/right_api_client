require File.join(File.dirname(__FILE__), 'spec_helper')
require 'irb'
require 'date'
require 'right_api_client/instance_facing'

require '/var/spool/cloud/user-data'

describe "Instance Facing Api" do
  before(:all) do
    account_id, token = ENV['RS_API_TOKEN'].split(/:/)
    @instance = RightApi::InstanceFacing.new(:instance_token => token, :account_id => account_id, :api_url => "https://#{ENV['RS_SERVER']}")
  end

#  it "returns correct device naming" do
#    @instance.reset
#
#    @volname = "spec_test_correct_device_naming_#{$$}"
#
#    @instance.create_and_attach_volumes(@volname, 1, "1")
#    api_name = @instance.volume_attachments.first.show.device
#    api_name.gsub!(/^\/dev\//,"")
#    IO.read("/proc/partitions").should include(api_name)
#  end
#
#  it "will backup" do
#    @instance.reset
#
#    @volname = "spec_test_will_backup"
#    @lineage = "#{@volname}_test_lineage"
#    @backup_options = { :lineage => @lineage,
#                        :name => @volname,
#                        :max_snapshots => 1,
#                        :keep_dailies => 1,
#                        :keep_weeklies => 1,
#                        :keep_monthlies => 1,
#                        :keep_yearlies => 1 }
#
#    @instance.create_and_attach_volumes(@volname, 2, "1")
#    @instance.backup(@backup_options)
#  end


  it "will restore" do
    @instance.reset

    @volname = "spec_test_will_restore_#{$$}"

    @lineage = "#{@volname}_test_lineage"
    @backup_options = { :lineage => @lineage,
                        :name => @volname,
                        :max_snapshots => 5,
                        :keep_dailies => 5,
                        :keep_weeklies => 5,
                        :keep_monthlies => 5,
                        :keep_yearlies => 5 }

    puts "VOLNAME = #{@volname}"

    @instance.create_and_attach_volumes(@volname, 1, "5")
    puts "waiting 60 seconds after sending creating and attaching volumes command"
    sleep(60)

    # get device id just attached
    device_name = @instance.volume_attachments.first.show.device
    puts "waiting 60 seconds after sending creating attaching volumes command"
    sleep(60)

    # Writing data to device
    sfdisk_cmd = "sfdisk #{device_name} << EOF\n"
    sfdisk_cmd << ";\n"
    sfdisk_cmd << "EOF\n"

    system(sfdisk_cmd)
    sleep 3
    system("mkfs.ext3 #{device_name}1")
    system("mount #{device_name}1 /mnt")
    system("dd if=/dev/zero of=/mnt/200m bs=1M count=200")
    system("umount /mnt")

    puts "waiting 30 seconds after writing to volumes"
    sleep(30)

    @instance.backup(@backup_options)
    puts "waiting 120 seconds after sending backup command"
    sleep(120)

    @instance.reset
    puts "waiting 120 seconds after sending reset command"
    sleep(120)
    
    backup = @instance.find_latest_backup(@lineage)
    puts "Backup found"
    puts "waiting 120 seconds after finding lastest backup"
    sleep(120)

    backup.restore(:instance_href => @instance.href)
    puts "marker after restore command"
  end

end
