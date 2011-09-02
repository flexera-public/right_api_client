#
# Mixes in instance facing api backups functionality
#

require 'right_api_client/client'
module RightApi
  class InstanceFacing
    attr_accessor :client

    def initialize(params)
       @client = RightApi::Client.new(params)
       @logger = @client.log(STDOUT)
    end

    # Using volume name which is set to the same as the lineage name we will lookup the attached device names on this instance.
    # Returns: array of device names (ie: ["/dev/xvdb"])
    # ~ <lineage> String: the lineage
    def attached_devices_for_lineage(lineage)
      this_line = volume_attachments.select { |s| s.volume.show.name == lineage }
      this_line.map { |m| m.show.device }
    end

    # returns device list
    def generate_physical_device_names(count)
      x=IO.read("/proc/partitions")
      if x =~ / vda/
        # we're in CDC/kvm?
        devstr = "vd"
      elsif x =~ / sda/
        # we're in euca/kvm
        devstr = "sd"
      elsif x =~ / xvda/
        # we're in xen
        devstr = "xvd"
      end

      lines = x.split("\n")
      lines.last =~ /#{devstr}([a-z]+)[0-9]*$/
      last_dev_letter = $1

      new_dev_list = []
      devrange = (last_dev_letter .. 'zzz').to_a

      count.to_i.times do |device_gen|
        new_dev_list << "/dev/#{devstr}#{devrange[device_gen+1]}"
      end

      new_dev_list
    end

    # Requires options[:lineage]
    def backup(options)
      backup_hrefs = volume_attachments.map { |m| m.show.href }
      params = { :backup => { :lineage => options[:lineage],
                               :name => options[:name],
                               :volume_attachment_hrefs => backup_hrefs}}
      new_backup = @client.backups.create(params)
      # TODO: backups need to be a separate call .. for tight chef integration
      while (completed = new_backup.show.completed) != true
        puts "waiting for backup to complete - completed is #{completed}"
        sleep 2
      end
      new_backup.update(:backup => {:committed => "true"})
      @client.backups.cleanup(:lineage => options[:lineage],
                              :keep_last => options[:max_snapshots],
                              :dailies => options[:keep_dailies],
                              :weeklies => options[:keep_weeklies],
                              :monthlies => options[:keep_monthlies],
                              :yearlies => options[:keep_yearlies]
                             )

      new_backup
    end

    # restores and waits for restore to finish
    # current statuses observed:
    # - pending
    # - failed
    # - in-progress
    # - completed
    def restore(backup)
      restore = backup.restore(:instance_href => href)

      while (status = restore.show.summary.split(':').first) != 'completed'
        raise "restore failed!" if status == 'failed'
        puts "waiting for restore to complete - status is #{status}"
        sleep 2
      end

      restore
    end

    # Returns latest backup as RightApiClient::Resource
    # ~ <lineage> String: the lineage
    # TODO - better filters specific to clouds
    def find_latest_backup(lineage)
      backup = @client.backups.index(:lineage => lineage, :filter => [ "latest_before==#{Time.now.utc.strftime('%Y/%m/%d %H:%M:%S %z')}", "committed==true", "completed==true"] )
      raise "FATAL: no backups found" if backup.empty?
      backup.first.show
    end

    def href
      @client.get_instance.href
    end

    # Returns true if Instance is running on Cloud.com
    def is_cdc?
      return true if IO.read('/etc/rightscale.d/cloud').chomp =~ /cloud\.com|vmops|cloudstack/
      return false
    end

    # Returns true if Instance is running on Eucalyptus
    def is_euca?
      return true if IO.read('/etc/rightscale.d/cloud').chomp =~ /eucalyptus/
      return false
    end

    # Create and attach blank volumes
    # ~ volname - String to use for volume name
    # ~ numvols - Integer number of volumes to create
    # ~ volume_size - Integer size of each volume
    # Returns array of device names that were attached
    def create_and_attach_volumes(volname, numvols, volume_size)
      physical_device_names = generate_physical_device_names(numvols)
      # TODO: make volumes, then wait for attach
      attached_volumes = []
      numvols.times do |index|
        instance = @client.get_instance
        datacenter_link = instance.links.detect { |i| i["rel"] == "datacenter" }
        datacenter_href = datacenter_link["href"]
        # create the volume
        params = {:volume => {:datacenter_href => datacenter_href, :name => volname}}
        # get the volume_type (CDC only)
        if is_cdc?
          params[:volume][:volume_type_href] = @client.volume_types.index.first.show.href
        # euca requires size
        else
          params[:volume][:size] = volume_size.to_s
        end

        new_vol = @client.volumes.create(params)
        puts "waiting for volume to create - initial current status = #{new_vol.show.status}"
        while ((status = new_vol.show.status) != "available")
          puts "waiting for volume to create - status is #{status}"
          sleep 2
        end

        # attach the new volume
        params = {:volume_attachment => {:volume_href => new_vol.show.href, :instance_href => instance.href, :device => physical_device_names[index] } }
        new_attachment = @client.volume_attachments.create(params)
        puts "waiting for volume to attach - initial current status = #{new_vol.show.status}"
        while ((status = new_vol.show.status) != "in-use") && ((state = new_attachment.show.state) != "attached") do
          puts "attaching - waiting for volume to attach - status is #{status} / #{state}"
          sleep 2
        end
        attached_volumes << new_attachment
      end
      av = attached_volumes.map { |m| m.show.device }
      #av = sanitize_device_list(av)
      puts("attached #{av.join(',')}")
      av
    end

    def sanitize_device_list(device_list)
      x=IO.read("/proc/partitions")
      new_dev_list = []
      if x =~ / vda/
        # we're in euca/kvm
        device_list.each do |dev|
          new_dev << dev.gsub(/xvd/,"vd")
        end
      end
    end

    # Returns list of volume attachments for THIS instance
    def volume_attachments
      va = @client.volume_attachments.index(:filter => ["instance_href==#{href}"])
      myattachments = []
      va.each do |a|
        myattachments << a unless a.show.device.include?('unknown')
      end
      myattachments
    end

    # Detaches all non-root volumes and deletes them.
    def reset
      delete_these = []
      # Detach

      myattachments = volume_attachments
      myattachments.each do |attachment|
        while ((state = @client.volume_attachments(:id => attachment.href.split('/').last).show.state) != "attached") do

          puts "resetting - waiting for volume to attach - status is #{state}"
          sleep 2
        end
        delete_these << attachment.show.volume
        attachment.destroy
      end

      # Delete (Is this too destructive?)
      delete_these.each do |found|
        found.destroy
      end
    end

  end
end
