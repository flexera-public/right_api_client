
module RightApi
  # Represents a Resource. This is a fillter class for a single resource
    # This class once again dynamically adds methods and properties to instances depending on what type of resource they are.
  class Resource
    include RightApiHelper

    # The API does not provide information about the basic actions that can be
    # performed on a resource so define them here:
    RESOURCE_ACTIONS = {
      :destroy => ['deployment', 'server_array', 'server', 'ssh_key', 'volume', 'volume_snapshot', 'volume_attachment', 'backup'],
      :update => ['deployment', 'instance', 'server_array', 'server', 'backup'],
      :no_show => ['input', 'session', 'resource_tag']  # Once again, easier to define those that don't have a show call associated with them
    }


    # Will create a (or an array of) new Resource object(s)
    # All parameters are treated as read only
    def self.process(client, resource_type, path, data={})
      if data.kind_of?(Array)  # This is needed for the index call to return an array of all the resources
        data.collect do |obj|
          #ideally all objects should have a links attribute that will have a link called 'self' which is the href. For exceptions like inputs, use the path itself.
          obj_href = client.get_href_from_links(obj["links"]) || path
          ResourceDetail.new(client, resource_type, obj_href, obj)
        end
      else
        RightApi::Resource.new(client, resource_type, path, data)
      end
    end

    def inspect
      "#<#{self.class.name} " +
      "resource_type=\"#{@resource_type}\"" +
      "#{', name='+@hash["name"].inspect if @hash.has_key?("name")}" +
      "#{', resource_uid='+@hash["resource_uid"].inspect if @hash.has_key?("resource_uid")}>"
    end

    # Hash is only used for index calls so we can parse out the name and resource_uid for the inspect call
    # All parameters are treated as read only
    def initialize(client, resource_type, href, hash={})
      if INCONSISTENT_RESOURCE_TYPES.has_key?(resource_type)
        resource_type = INCONSISTENT_RESOURCE_TYPES[resource_type]
      end
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
          RightApi::ResourceDetail.new(client, *client.do_get(href, *args))
        end
      end
    end
  end
end
