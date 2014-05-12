module RightApi
  # Represents a Resource. This is a filler class for a single resource.
  # This class dynamically adds methods and properties to instances depending on what type of resource they are.
  class Resource
    include Helper
    attr_reader :client, :href, :resource_type

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

    # Data may already be 'detailed' (i.e. has a self-href) so avoid returning
    # an undetailed resource in that case. this is because calling #show on
    # the undetailed resource would generate a redundant call to
    #   client#do_get(...)
    #
    # FIX: this logic should probably be the behavior of the Resource.process()
    # method but we are not willing to change legacy behavior for RightAPI v1.5.
    # the RightAPI v1.6+ client should only use this logic going forward.
    def self.process_detailed(client, resource_type, path, data={})
      if data.kind_of?(Array)
        process(client, resource_type, path, data)
      else
        if obj_href = client.get_href_from_links(data["links"])
          ResourceDetail.new(client, resource_type, obj_href, data)
        else
          # no self-href means make an undetailed resource (legacy behavior).
          process(client, resource_type, path, data)
        end
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
      define_instance_method('destroy') do |*args|
        client.send(:do_delete, href, *args)
      end

      # Add update method to relevant resources
      define_instance_method('update') do |*args|
        client.send(:do_put, href, *args)
      end

      # Add show method to relevant resources
      define_instance_method('show') do |*args|
        RightApi::ResourceDetail.new(client, *client.send(:do_get, href, *args))
      end
    end

    # Any other method other than standard actions(show,update,destroy)
    # is simply appended to the href and called with a POST.
    def method_missing(m, *args)
      client.send(:do_post, [ href, m.to_s ].join('/'), *args)
    end
  end
end
