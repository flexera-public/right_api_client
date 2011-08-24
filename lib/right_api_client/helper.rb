#
# Methods shared by the RightApiClient, Resource and resource arrays.
#


module RightApiHelper

  # Some resource_types are not the same as the last thing in the URL: put these here to ensure consistency
  INCONSISTENT_RESOURCE_TYPES = {
    'current_instance' => 'instance',
    'data'  => 'monitoring_metric_data',
    'setting'  => 'multi_cloud_image_setting'
  }

  # Helper used to add methods to classes dynamically
  def define_instance_method(meth, &blk)
    (class << self; self; end).module_eval do
      define_method(meth, &blk)
    end
  end

  # Helper method that returns all api methods available to a client or resource
  def api_methods
    self.methods(false)
  end

  # Helper method that creates instance methods out of the associated resources from links
  # Some resources have many links with the same rel.
  # We want to capture all these href in the same method, returning an array
  def get_associated_resources(client, links, associations)
    # First go through the links and group the rels together
    rels = {}
    links.each do |link|
      if rels[link['rel'].to_sym]  # if we have already seen this rel attribute
        rels[link['rel'].to_sym] << link['href']
      else
        rels[link['rel'].to_sym] = [link['href']]
      end
    end

    # Note: hrefs will be an array, even if there is only one link with that rel
    rels.each do |rel,hrefs|
      # Add the link to the associations set if present. This is to accommodate ResourceDetail objects
      associations << rel if associations != nil

      # Create methods so that the link can be followed
      define_instance_method(rel) do |*args|
        if hrefs.size == 1 # Only one link for the specific rel attribute
          if has_id(*args) || is_singular?(rel)
            # User wants a single resource. Either doing a show, update, delete...
            # get the resource_type

            # Special case: calling .data you don't want a resources object back
            # but rather all its details since you cannot do a show
            return RightApi::ResourceDetail.new(client, *client.do_get(hrefs.first, *args)) if rel == :data

            if is_singular?(rel)
              # Then the href will be: /resource_type/:id
              resource_type = get_singular(hrefs.first.split('/')[-2])
            else
              # Else the href will be: /resource_type
              resource_type = get_singular(hrefs.first.split('/')[-1])
            end
            path = add_id_and_params_to_path(hrefs.first, *args)
            RightApi::Resource.process(client, resource_type, path)
          else
            # Returns the class of this resource
            resource_type = hrefs.first.split('/')[-1]
            path = add_id_and_params_to_path(hrefs.first, *args)
            RightApi::Resources.new(client, path, resource_type)
          end
        else
          # There were multiple links with the same relation name
          # This occurs in tags.by_resource
          resources = []
          if has_id(*args) || is_singular?(rel)
            hrefs.each do |href|
              # User wants a single resource. Either doing a show, update, delete...
              if is_singular?(rel)
                resource_type = get_singular(href.split('/')[-2])
              else
                resource_type = get_singular(href.split('/')[-1])
              end
              path = add_id_and_params_to_path(href, *args)
              resources << RightApi::Resource.process(client, resource_type, path)
            end
          else
            hrefs.each do |href|
              # Returns the class of this resource
              resource_type = href.split('/')[-1]
              path = add_id_and_params_to_path(href, *args)
              resources << RightApi::Resources.new(client, path, resource_type)
            end
          end
          # return the array of resource objects
          resources
        end
      end
    end
  end


  # Helper method that checks whether params contains a key :id
  def has_id(params = {})
    params.has_key?(:id)
  end

  # Helper method that adds filters and other parameters to the path
  # Normally you would just pass a hash of query params to RestClient,
    # but unfortunately it only takes them as a hash, and for filtering
    # we need to pass multiple parameters with the same key. The result
    # is that we have to build up the query string manually.
  # This does not modify the original_path but will change the params
  def add_id_and_params_to_path(original_path, params = {})
    path = original_path.dup

    path += "/#{params.delete(:id)}" if has_id(params)
    filters = params.delete(:filter)
    params_string = params.map{|k,v| "#{k.to_s}=#{CGI::escape(v.to_s)}" }.join('&')
    if filters && filters.any?
      path += "?filter[]=" + filters.map{|f| CGI::escape(f) }.join('&filter[]=')
      path += "&#{params_string}"
    else
      path += "?#{params_string}"
    end

    # If present, remove ? and & at end of path
    path.chomp!('&')
    path.chomp!('?')
    path
  end

  # Helper method that inserts the given term at the correct place in the path
  # If there are parameters in the path then insert it before them.
  # Will not change path
  def insert_in_path(path, term)
    if path.index('?')
      # sub returns a copy of path
      new_path = path.sub('?', "/#{term}?")
    else
      new_path = "#{path}/#{term}"
    end
  end

  # Helper method that checks whether the string is singular
  def is_singular?(str)
    return true if ['data'].include?(str.to_s)
    (str.to_s)[-1] != 's'
    #str.pluralize.singularize == str
  end

  # Does not modify links
  def get_href_from_links(links)
    if links
      self_link = links.detect{|link| link["rel"] == "self"}
      return self_link["href"] if self_link
    end
    return nil
  end

  # This will modify links
  def get_and_delete_href_from_links(links)
    if links
      self_link = links.detect{|link| link["rel"] == "self"}
      return links.delete(self_link)["href"] if self_link
    end
    return nil
  end

  # Will not change obj
  def get_singular(obj)
    str = obj.to_s.dup
    str.chomp!('s')
    str
  end
end
