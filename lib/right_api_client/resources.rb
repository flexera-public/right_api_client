module RightApi
  # This class defines the different resource types and the methods that one can call on them
  # This class dynamically adds methods and properties to instances depending on what type of resource they are.
  # This is a filler class so that we don't always have to do an index before anything else
  # This class gets instantiated when the user calls (for example) client.clouds ... (ie. when you want the generic class: no id present)
  class Resources
    include Helper

    attr_reader :client, :path
    def inspect
      "#<#{self.class.name} " +
      "resource_type=\"#{@resource_type}\">"
    end

    # Since this is just a filler class, only define instance methods and the method api_methods()
    # Resource_type should always be plural.
    # All parameters are treated as read only
    def initialize(client, path, resource_type)
      @client = client
      @path   = path

      if INCONSISTENT_RESOURCE_TYPES.has_key?(get_singular(resource_type))
        resource_type = INCONSISTENT_RESOURCE_TYPES[get_singular(resource_type)] + 's'
      end
      @resource_type = resource_type
      # Add create methods for the relevant root RightApi::Resources
      self.define_instance_method('create') do |*args|
        client.send(:do_post, path, *args)
      end

      # Add in index methods for the relevant root RightApi::Resources
      self.define_instance_method('index') do |*args|
        # Session uses .index like a .show (so need to treat it as a special case)
        if resource_type == 'session'
          ResourceDetail.new(client, *client.send(:do_get, path, *args))
        else
          RightApi::Resource.process(client, *client.send(:do_get, path, *args))
        end
      end

      # Adding in special cases
      Helper::RESOURCE_SPECIAL_ACTIONS[resource_type].each do |meth, action|
        # Insert_in_path will NOT modify path
        action_path = insert_in_path(path, meth)
        self.define_instance_method(meth) do |*args|
          client.send(action, action_path, *args)
        end
      end if Helper::RESOURCE_SPECIAL_ACTIONS[resource_type]
    end

    # Any other method other than standard actions (create, index)
    # is simply appended to the href and called with a POST.
    def method_missing(m, *args)
      client.send(:do_post, [ href, m.to_s ].join('/'), *args)
    end
  end
end
