
# view = default, inputs...
# filters when can add them
# look at the two print one

# Questions:

# Instance-facing-calls don't use the same notation as for normal calls

# Read through this code
# put them in separate files
# Do the instance-facing-calls
# make gem

# test cases/ specs


require 'rest_client' # rest_client 1.6.1
require 'json'
require 'set'
require 'cgi'

# RightApiClient has the generic get/post/delete/put calls that are used
# by resources
class RightApiClient

  ROOT_RESOURCE = '/api/session'
  ROOT_INSTANCE_RESOURCE = '/api/session/instance'

  # permitted parameters for initializing
  AUTH_PARAMS = %w(email password account_id api_url api_version cookies instance_token)
  
  
  
# |||||||||||||||||||||||||||||||||||||||||||||||||||||| HELPER MODULE |||||||||||||||||||||||||||||||||||||||||||||||||||| 
  #
  # Methods shared by the RightApiClient, Resource and resource arrays.
  #
  module Helper

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
    
    # Helper method that returns associated resources from links
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
        # Add the link to the associations set if present. This is to accommodate Resource objects
        associations << rel if associations != nil
        
        # Create methods so that the link can be followed
        define_instance_method(rel) do |*args|
          if hrefs.size == 1 # Only one link for the specific rel attribute
            if has_id(*args) || is_singular?(rel)
              # User wants a single resource. Either doing a show, update, delete...
              path = add_id_and_params_to_path(hrefs.first, *args)
              # The resource_type is the singular form the the method (ie. clouds will turn to cloud)
              resource_type = make_singular(rel)
              Resource.process(client, resource_type, path)
            else
              # Returns the class of this resource
              resource_type = rel
              Resources.new(client, hrefs.first, resource_type)
            end
          else
            # There were multiple links with the same relation name
            # This occurs in tags.by_resource 
            resources = []
            p "we are heerererere"
            if has_id(*args) || is_singular?(rel)
              hrefs.each do |href|
                # User wants a single resource. Either doing a show, update, delete...
                path = add_id_and_params_to_path(href, *args)
                # The resource_type is the singular form the the method (ie. clouds will turn to cloud)
                resource_type = make_singular(rel)
                resources << Resource.process(client, resource_type, path)
              end
            else
              hrefs.each do |href|
                # Returns the class of this resource
                resource_type = rel
                resources << Resources.new(client, href, resource_type)
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
    def add_id_and_params_to_path(path, params = {})
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
    def insert_in_path(path, term)
      if path.index('?')
        new_path = path.sub('?', "/#{term}?")
      else
        new_path = "#{path}/#{term}"
      end
    end
    
    # Helper method that checks whether the string is singular
    def is_singular?(str)
      (str.to_s)[-1] != 's'
      #str.pluralize.singularize == str
    end
    
    def get_href_from_links(links)
      self_index = links.any? && links.each_with_index do |link, idx|
        if link['rel'] == 'self'
          break idx
        end

        if idx == links.size-1
          break nil
        end
      end

      if self_index
        return links.delete_at(self_index)['href']
      end
      return nil
    end
    
    def make_singular(str)
      str.to_s.chomp!('s')
    end
  end
  

# ||||||||||||||||||||||||||||||||||||||||||||||||||| RightAPI Client |||||||||||||||||||||||||||||||||||||||||||||||||||||
  include Helper

  # The cookies for our client.
  attr_reader :cookies, :instance_token

  def initialize(args)

    # Default params
    @api_url, @api_version = 'https://my.rightscale.com', '1.5'

    # Initializing all instance variables from hash
    args.each { |key,value|
      instance_variable_set("@#{key}", value) if value && AUTH_PARAMS.include?(key.to_s)
    } if args.is_a? Hash

    raise 'This API Client is only compatible with RightScale API 1.5 and upwards.' if (Float(@api_version) < 1.5)
    @client = RestClient::Resource.new(@api_url)

    # There are three options for login: credentials, instance token, or if the user already has the cookies they can just use those
    @cookies ||= login()

    if @instance_token
      # Add in the top level links for instance_facing_calls here:
      resource_type, path, data = self.do_get(ROOT_INSTANCE_RESOURCE)
      # The instance's href
      instance_href = get_href_from_links(data['links'])
      cloud_href = instance_href.split('/instances')[0]
      # Don't follow the links here?
      define_instance_method(:get_instance) do |*params|
        ResourceDetail.new(self, resource_type, path, data)
      end

      [:volumes, :volume_attachments, :volume_snapshots, :volume_types].each do |meth|
        define_instance_method(meth) do |*args|
          path = cloud_href + '/' + meth.to_s
          if has_id(*args)
            path = add_id_and_params_to_path(path, *args)
            Resource.process(self, make_singular(meth), path)
          else
            Resources.new(self, path, meth)
          end
        end
      end
        
      define_instance_method(:live_tasks) do |*args|
        path = instance_href + '/live/tasks'
        if has_id(*args) # can only call this with an id
          path = add_id_and_params_to_path(path, *args)
          Resource.process(self, 'live_task', path)
        end
      end

      define_instance_method(:backups) do |*args|
        path = '/api/backups'
        if has_id(*args)
            path = add_id_and_params_to_path(path, *args)
            Resource.process(self, 'backup', path)
        else
            Resources.new(self, path, :backups)
        end
      end
    else 
      # Not an instance-facing-call: 
      # Session is the root resource that has links to all the base resources
      define_instance_method(:session) do |*params|
        Resources.new(self, ROOT_RESOURCE, 'session')
      end
      # Allow the base resources to be accessed directly
      get_associated_resources(self, session.index.links, nil)
    end
  end
  
  
  
  def to_s
    "#<RightApiClient>"
  end
    
  # Log HTTP calls to file (file can be STDOUT as well)
  def log(file)
    RestClient.log = file
  end

# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| REST Specific |||||||||||||||||||||||||||||||||||||||||||
  # Users shouldn't need to call the following methods directly

  # you can login with username and password or with an instance_token
  def login
    if @instance_token
      params = {
        'instance_token' => @instance_token
      }
      path = ROOT_INSTANCE_RESOURCE
    else
      params = {
        'email'        => @email,
        'password'     => @password,
      }
      path = ROOT_RESOURCE
    end
    params['account_href'] = "/api/accounts/#{@account_id}"

    response = @client[path].post(params, 'X_API_VERSION' => @api_version) do |response, request, result, &block|
      case response.code
      when 302
        response
      else
        response.return!(request, result, &block)
      end
    end
    response.cookies
  end

  # Returns the request headers
  def headers
    {'X_API_VERSION' => @api_version, :cookies => @cookies, :accept => :json}
  end

  # Generic get
  def do_get(path, params={})
    # Resource id is a special param as it needs to be added to the path
    path = add_id_and_params_to_path(path, params)

    begin
      # Return content type so the resulting resource object knows what kind of resource it is.
      resource_type, body = @client[path].get(headers) do |response, request, result, &block|
        case response.code
        when 200
          # Get the resource_type from the content_type, the resource_type will
          # be used later to add relevant methods to relevant resources.
          type = ''
          if result.content_type.index('rightscale')
            type = get_resource_type(result.content_type)
          end

          [type, response.body]
        else
          raise "Unexpected response #{response.code.to_s}, #{response.body}"
        end
      end
      #Session cookie is expired or invalid
    rescue RuntimeError => e
      if re_login?(e)
        @cookies = login()
        retry
      else
        raise e
      end
    end

    data = JSON.parse(body)

    [resource_type, path, data]
  end
  
  # Generic post
  def do_post(path, params={})
    begin
      @client[path].post(params, headers) do |response, request, result, &block|
        case response.code
        when 201, 202
          # Create and return the resource
          href = response.headers[:location]
          relative_href = href.split(@api_url)[-1]
          # Return the resource that was just created
          # Determine the resource_type from the href: (eg. .../clouds/id).
          # This is based on the assumption that we can determine the resource_type without doing a do_get
          resource_type = make_singular(relative_href.split('/')[-2])
          Resource.process(self, resource_type, relative_href)
        when 200..299
          # this is needed for the tags Resource -- which returns a 200 and has a content type
          # therefore, a resource object needs to be returned
          if response.code == 200 && response.headers[:content_type].index('rightscale')
            resource_type = get_resource_type(response.headers[:content_type])
            Resource.process(self, resource_type, path)
          else          
            response.return!(request, result, &block)
          end
        else
          raise "Unexpected response #{response.code.to_s}, #{response.body}"
        end
      end
    rescue RuntimeError => e
      if re_login?(e)
        @cookies = login()
        retry
      else
        raise e
      end
    end
  end

  # Generic delete
  def do_delete(path)
    begin
      @client[path].delete(headers) do |response, request, result, &block|
        case response.code
        when 200
        else
          raise "Unexpected response #{response.code.to_s}, #{response.body}"
        end
      end
    rescue RuntimeError => e
      if re_login?(e)
        @cookies = login()
        retry
      else
        raise e
      end
    end
  end

  # Generic put
  def do_put(path, params={})
    begin
      @client[path].put(params, headers) do |response, request, result, &block|
        case response.code
        when 204
        else
          raise "Unexpected response #{response.code.to_s}, #{response.body}"
        end
      end
    rescue RuntimeError => e
      if re_login?(e)
        @cookies = login()
        retry
      else
        raise e
      end
    end
  end

  def re_login?(e)
    e.message.index('403') && e.message =~ %r(.*Session cookie is expired or invalid) 
  end
  
  # returns the resource_type
  def get_resource_type(content_type)
    content_type.scan(/\.rightscale\.(.*)\+json/)[0][0]
  end


# ||||||||||||||||||||||||||||||||||||||||||||| RESOURCES||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
  
  # This class defines the different resource types and the methods that one can call on them
  # This class dynamically adds methods and properties to instances depending on what type of resource they are.
    # This is a filler class so that we don't always have to do an index before anything else
    # This class gets instantiated when the user calls (for example) client.clouds ... (ie. when you want the generic class: no id present) 
  class Resources
    include Helper
    # These are the actions that you can call on this resource class
    RESOURCE_TYPE_ACTIONS = {
      :create => [:deployments, :server_arrays, :servers, :ssh_keys, :volumes, :volume_snapshots, :volume_attachments],
      :no_index => [:tags, :tasks]    # Easier to specify the resources that don't need an index call
    }
    
    # Some resources have methods that operate on the resource type itself 
      # and not on a particular one (ie: without specifing an id). Place these here:
    RESOURCE_TYPE_SPECIAL_ACTIONS = {
      :instances => {:multi_terminate => 'do_post', :multi_run_executable => 'do_post'},
      :inputs => {:multi_update => 'do_put'},
      :tags => {:by_tag => 'do_post', :by_resource => 'do_post', :multi_add => 'do_post', :multi_delete =>'do_post'},
      :backups => {:cleanup => 'do_post'} 
    }
    
    def inspect
      "#<#{self.class.name} " +
      "resource_type=\"#{@resource_type}\">"
    end
    
    # Since this is just a fillter class, only define instance methods and the method api_methods()
    # Resource_type should always be plural.
    def initialize(client, path, resource_type)
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
          # Session uses .index like a .show
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
  
# ||||||||||||||||||||||||||||||||||||||||||||||||| SINGLE RESOURCE ||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
  
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
  
  class ResourceDetail
    include Helper
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

      hash['href'] = get_href_from_links(links)
      
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

      # @@ look at what this does
      hash.each do |k, v|
        p "The hash is ", hash
        # If a parent resource is requested with a view then it might return
        # extra data that can be used to build child resources here, without
        # doing another get request.
        if associations.include?(k.to_sym)
          # We could use one rescue block rather than these multiple ifs, but
          # exceptions are slow and the whole points of this code block is
          # optimization so we'll stick to using ifs.

          # v might be an array or hash so use include rather than has_key
          if v.include?('links')
            p "%%%%%%%%% optimization"
            child_self_link = v['links'].find { |target| target['rel'] == 'self' }
            if child_self_link
              child_href = child_self_link['href']
              if child_href
                # Currently, only instances need this optimization, but in the
                # future we might like to extract resource_type from child_href
                # and not hard-code it.
                if child_href.index('instance')
                  # No special case, no data, path=child_href
                  define_instance_method(k) { Resource.process(client, 'instance', child_href, v) }
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

