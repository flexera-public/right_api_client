module RightApi
  # Represents a Resource. This is a filler class for a single resource.
  # This class dynamically adds methods and properties to instances depending on what type of resource they are.
  class Resource
    include Helper
    attr_reader :client, :href

    # Will create a (or an array of) new Resource object(s)
    # All parameters are treated as read only
    def self.process(client, resource_type, path, data={})
      if data.kind_of?(Array)  # This is needed for the index call to return an array of all the resources
        data.collect do |obj|
          # Ideally all objects should have a links attribute that will have a link called 'self' which is the href.
          # For exceptions like inputs, use the path itself.
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
      @client = client
      @resource_type = resource_type
      @hash = hash
      @href = href

      # Add destroy method to relevant resources
      define_instance_method('destroy') do
        client.do_delete(href)
      end

      # Add update method to relevant resources
      define_instance_method('update') do |*args|
        client.do_put(href, *args)
      end

      # Add show method to relevant resources
      define_instance_method('show') do |*args|
        RightApi::ResourceDetail.new(client, *client.do_get(href, *args))
      end
    end

    #Any other method other than standard actions(show,update,destroy) is simply appended to the href and
    #called with a POST.
    def method_missing(m, *args)
      action_href = href + "/" + m.to_s
      client.do_post(action_href, *args)
    end
  end
end
