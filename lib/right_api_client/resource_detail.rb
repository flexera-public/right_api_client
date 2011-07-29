
module RightApi
  class ResourceDetail
    include RightApiHelper
    attr_reader :client, :attributes, :associations, :actions, :raw, :resource_type
  
    def inspect
      "#<#{self.class.name} " +
      "resource_type=\"#{@resource_type}\"" +
      "#{', name='+name.inspect if self.respond_to?(:name)}" +
      "#{', resource_uid='+resource_uid.inspect if self.respond_to?(:resource_uid)}>"
    end
  
    def initialize(client, resource_type, href, hash)
      @client = client
      @resource_type = resource_type
      @raw = hash.dup
      @attributes, @associations, @actions = Set.new, Set.new, Set.new
    
      links = hash.delete('links') || []
      raw_actions = hash.delete('actions') || []

      self_hash = get_href_from_links(links)
      if self_hash != nil
        hash['href'] = self_hash
      end
    
      # Add links to attributes set and create a method that returns the links
      attributes << :links
      define_instance_method(:links) { return links }

      # Follow the actions:
        # API doesn't tell us whether a resource action is a GET or a POST, but
        # I think they are all post so add them all as posts for now.
      raw_actions.each do |action|
        action_name = action['rel']
        # Add it to the actions set
        actions << action_name.to_sym

        define_instance_method(action_name.to_sym) do |*args|
          href = hash['href'] + "/" + action['rel']
          client.do_post(href, *args)
        end
      end

      # Follow the links to create methods
      if !client.instance_token
        get_associated_resources(client, links, associations)
      end

      # Some resources are not linked together, so they have to be manually
      # added here.
      case resource_type
      when 'instance'
        define_instance_method('live_tasks') do |*args|
          if has_id(*args)
            path = href + '/live/tasks'
            path = add_id_and_params_to_path(path, *args)
            RightApi::Resource.process(client, 'live_task', path)
          end
        end
      end
    
      hash.each do |k, v|
        # If a parent resource is requested with a view then it might return
        # extra data that can be used to build child resources here, without
        # doing another get request.
        if associations.include?(k.to_sym)
          # We could use one rescue block rather than these multiple ifs, but
          # exceptions are slow and the whole points of this code block is
          # optimization so we'll stick to using ifs.

          # v might be an array or hash so use include rather than has_key
          if v.include?('links')
            child_self_link = v['links'].find { |target| target['rel'] == 'self' }
            if child_self_link
              child_href = child_self_link['href']
              if child_href
                # Currently, only instances need this optimization, but in the
                # future we might like to extract resource_type from child_href
                # and not hard-code it.
                if child_href.index('instance')
                  # No special case, no data, path=child_href
                  define_instance_method(k) { RightApi::Resource.process(client, 'instance', child_href, v) }
                end
              end
            end
          end
        else
          # Add it to the attributes set and create a method for it
          attributes << k.to_sym
          define_instance_method(k) { return v }
        end
      end
    end
  end
end