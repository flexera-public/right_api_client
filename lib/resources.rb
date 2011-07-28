require 'rest_client' # rest_client 1.6.1
require 'json'
require 'set'
require 'cgi'


require File.join(File.dirname(__FILE__), 'right_api_client')
require File.join(File.dirname(__FILE__), 'resource')
require File.join(File.dirname(__FILE__), 'resource_detail')
require File.join(File.dirname(__FILE__), 'helper')


# This class defines the different resource types and the methods that one can call on them
# This class dynamically adds methods and properties to instances depending on what type of resource they are.
  # This is a filler class so that we don't always have to do an index before anything else
  # This class gets instantiated when the user calls (for example) client.clouds ... (ie. when you want the generic class: no id present) 
class Resources
  include Helper
  # These are the actions that you can call on this resource class
  RESOURCE_TYPE_ACTIONS = {
    :create => ['deployments', 'server_arrays', 'servers', 'ssh_keys', 'volumes', 'volume_snapshots', 'volume_attachments', 'backups'],
    :no_index => ['tags', 'tasks']    # Easier to specify the resources that don't need an index call
  }
  
  # Some resources have methods that operate on the resource type itself 
    # and not on a particular one (ie: without specifing an id). Place these here:
  RESOURCE_TYPE_SPECIAL_ACTIONS = {
    'instances' => {:multi_terminate => 'do_post', :multi_run_executable => 'do_post'},
    'inputs' => {:multi_update => 'do_put'},
    'tags' => {:by_tag => 'do_post', :by_resource => 'do_post', :multi_add => 'do_post', :multi_delete =>'do_post'},
    'backups' => {:cleanup => 'do_post'} 
  }
  
  def inspect
    "#<#{self.class.name} " +
    "resource_type=\"#{@resource_type}\">"
  end
  
  # Since this is just a fillter class, only define instance methods and the method api_methods()
  # Resource_type should always be plural.
  def initialize(client, path, resource_type)
    #if UNCONSISTENT_RESOURCE_TYPES.has_key?(resource_type.make_singular)
    @resource_type = resource_type
    # Add create methods for the relevant root resources
    if RESOURCE_TYPE_ACTIONS[:create].include?(resource_type)
      self.define_instance_method('create') do |*args|
        client.do_post(path, *args)
      end
    end
    
    # Add in index methods for the relevant root resources
    if !RESOURCE_TYPE_ACTIONS[:no_index].include?(resource_type)
      self.define_instance_method('index') do |*args|
        # Session uses .index like a .show (so need to treat it as a special case)
        if resource_type == 'session'
          ResourceDetail.new(client, *client.do_get(path, *args))
        else
          Resource.process(client, *client.do_get(path, *args))
        end
      end
    end
    
    # Adding in special cases
    RESOURCE_TYPE_SPECIAL_ACTIONS[resource_type].each do |meth, action|
      action_path = insert_in_path(path, meth)
      self.define_instance_method(meth) do |*args|
        client.send action, action_path, *args
      end
    end if RESOURCE_TYPE_SPECIAL_ACTIONS[resource_type]
  end
end