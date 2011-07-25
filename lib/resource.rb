require 'rest_client' # rest_client 1.6.1
require 'json'
require 'set'
require 'cgi'


require File.join(File.dirname(__FILE__), 'right_api_client')
require File.join(File.dirname(__FILE__), 'resources')
require File.join(File.dirname(__FILE__), 'resource_detail')
require File.join(File.dirname(__FILE__), 'helper')


# Represents a single resource returned by an API call
  # This class once again dynamically adds methods and properties to instances depending on what type of resource they are.
class Resource
  include Helper

  # The API does not provide information about the basic actions that can be
  # performed on a resource so define them here:
  RESOURCE_ACTIONS = {
    :destroy => ['deployment', 'server_array', 'server', 'ssh_key', 'volume', 'volume_snapshot', 'volume_attachment', 'backup'],
    :update => ['deployment', 'instance', 'server_array', 'server', 'backup'],
    :no_show => ['input', 'session', 'tag']  # Once again, easier to define those that don't have a show call associated with them
  }


  # Will create a (or an array of) new Resource object(s)
  def self.process(client, resource_type, path, data={})
    if data.kind_of?(Array)  # This is needed for the index call to return an array of all the resources
      data.map { |obj|
        # we need to get the path for this specific resource
        obj_path = client.get_href_from_links(obj["links"])
        Resource.new(client, resource_type, obj_path, obj) }
    else
      Resource.new(client, resource_type, path, data)
    end
  end
      
  def inspect
    "#<#{self.class.name} " +
    "resource_type=\"#{@resource_type}\"" +
    "#{', name='+@hash["name"].inspect if @hash.has_key?("name")}" +
    "#{', resource_uid='+@hash["resource_uid"].inspect if @hash.has_key?("resource_uid")}>"
  end

  # Hash is only used for index calls so we can parse out the name and resource_uid
  def initialize(client, resource_type, href, hash={})
    # For the inspect function:
    @resource_type = resource_type
    @hash = hash
    
    # Add destroy method to relevant resources
    if RESOURCE_ACTIONS[:destroy].include?(resource_type)
      define_instance_method('destroy') do
        client.do_delete(href)
      end
    end

    # Add update method to relevant resources
    if RESOURCE_ACTIONS[:update].include?(resource_type)
      define_instance_method('update') do |*args|
        client.do_put(href, *args)
      end
    end
    
    # Add show method to relevant resources
    if !RESOURCE_ACTIONS[:no_show].include?(resource_type)
      define_instance_method('show') do |*args|
        ResourceDetail.new(client, *client.do_get(href, *args)) 
      end
    end

    # Some resources are not linked together, so they have to be manually
    # added here.
    case resource_type
    when 'instance'
      define_instance_method('live_tasks') do |*args|
        if has_id(*args)
          path = href + '/live/tasks'
          path = add_id_and_params_to_path(path, *args)
          Resource.process(client, 'live_task', path)
        end
      end
    end
  end
end