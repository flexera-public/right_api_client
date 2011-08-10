require File.join(File.dirname(__FILE__), 'spec_helper')
require 'irb'
require 'date'
require 'right_api_client/instance_facing'
require '/var/spool/cloud/user-data'
describe "Instance Facing Api" do
  before(:all) do
    account_id, token = ENV['RS_API_TOKEN'].split(/:/)
    @client = RightApi::Client.new(:instance_token => token, :account_id => account_id)
    @client.log(STDOUT)
    @instance = RightApi::InstanceFacing.new(:instance_token => token, :account_id => account_id)
    @volname = "spec_test_five_billion"
    @lineage = "spec_test_five_billion_and#{rand(1000000)}"
    @client.headers[:cookies].should_not be_nil
    @backup_options = { :lineage => @lineage,
                        :name => @volname,
                        :max_snapshots => 1,
                        :keep_dailies => 1,
                        :keep_weeklies => 1,
                        :keep_monthlies => 1,
                        :keep_yearlies => 1 }
  end

  it "returns correct device naming" do
    @instance.reset
    @instance.create_and_attach_volumes(@volname, 1, "1")
    api_name = @instance.volume_attachments.first.show.device
    api_name.gsub!(/^\/dev\//,"")
    IO.read("/proc/partitions").should include(api_name)
  end

  it "will create from scratch" do
    @instance.reset
    prev_size = @instance.volume_attachments.size
    @instance.create_and_attach_volumes(@volname, 2, "1")
    currently_attached = @instance.volume_attachments.size
    currently_attached.should  == (prev_size + 2)
  end

  it "will backup" do
    @instance.reset
    @instance.create_and_attach_volumes(@volname, 2, "1")
    @instance.backup(@backup_options)
  end

  it "will restore" do
    @instance.create_and_attach_volumes(@volname, 2, "1")
    @instance.backup(@backup_options)
    @instance.reset
    backup = @instance.find_latest_backup(@lineage)
    backup.restore(:instance_href => @instance.href)
  end

end
