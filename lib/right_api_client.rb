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
  
  
  
  
  #
  # Methods shared by the RightApiClient, Resource and resource arrays.
  #
  module Helper

    # Helper used to add methods to classes
    def define_instance_method(meth, &blk)
      (class << self; self; end).module_eval do
        define_method(meth, &blk)
      end
    end

    # Helper method that returns all api methods available to a client
    # or resource
    def api_methods
      self.methods(false)
    end
    
    # Define methods that query the API for the associated resources
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
            if has_id(*args) || is_singular?(rel) # Want to get a single resource. Either doing a show, update, delete...
              SingleResource.process(client, *client.do_get(hrefs.first, *args))
            else
              #path = add_filters_to_path(hrefs.first, *args)
              ResourceType.new(client, hrefs.first, rel)
            end
          else
            # @@ To Do YIKES!
            resources = []
            hrefs.each do |href|
              resources << SingleResource.process(client, *client.do_get(href, *args))
            end
            # return the array of resource objects
            resources
          end
        end 
      end
    end
    
    def add_id_to_path(path, params = {})
      path += "/#{params.delete(:id)}" if has_id(params)
      path
    end
    
    def has_id(params = {})
      params.has_key?(:id)
    end
    
     # Normally you would just pass a hash of query params to RestClient,
      # but unfortunately it only takes them as a hash, and for filtering
      # we need to pass multiple parameters with the same key. The result
      # is that we have to build up the query string manually.
    def add_filters_to_path(path, params ={})
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
    
    # Insert the given term at the correct place in the path, so
    # if there are parameters in the path then insert it before them.
    def insert_in_path(path, term)
      if path.index('?')
        new_path = path.sub('?', "/#{term}?")
      else
        new_path = "#{path}/#{term}"
      end
    end
    
    def is_singular?(str)
      str = str.to_s
      str[-1] != 's'
      #str.pluralize.singularize == str
    end
  end
  

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
      define_instance_method(:get_instance) do |*params|
        SingleResource.process(self, *self.do_get(ROOT_INSTANCE_RESOURCE, *params))
      end
      # Like tags, you cannot call api/clouds when using an instance_token
      # @@ To Do
      define_instance_method('clouds') do |*args|
        if has_id(*args)
          SingleResource.process(client, *client.do_get(hrefs.first, *args))
        end
      end
      
      define_instance_method('backups') do |*args|
        path = '/api/backups'
        if has_id(*args)
            SingleResource.process(client, *client.do_get(path, *args))
        else
            ResourceType.new(client, path, 'backups')
        end
      end
    else  
      # Session is the root resource that has links to all the base resources,
      # to the client since they can be accessed directly
      define_instance_method(:session) do |*params|
        SingleResource.process(self, *self.do_get(ROOT_RESOURCE, *params))
      end
      get_associated_resources(self, session.links, nil)
    end
  end
  
  
  
  def to_s
    "#<RightApiClient>"
  end
    
  # Log HTTP calls to file (file can be STDOUT as well)
  def log(file)
    RestClient.log = file
  end

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

  def headers
    {'X_API_VERSION' => @api_version, :cookies => @cookies, :accept => :json}
  end

  # Generic get
  def do_get(path, params={})
    # Resource id is a special param as it needs to be added to the path
    path = add_id_to_path(path, params)
    
    path = add_filters_to_path(path, params)

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

    [data, resource_type]
  end
  
  # Generic post
  def do_post(path, params={})
    begin
      @client[path].post(params, headers) do |response, request, result, &block|
        case response.code
        when 201, 202
          # Create and return the resource
          href = response.headers[:location]
          href = href.split(@api_url)[-1]
          SingleResource.process(self, *self.do_get(href))
        when 200..299
          # this is needed for the tags Resource -- which returns a 200 and has a content type
          # therefore, a resource object needs to be returned
          if response.code == 200 && response.headers[:content_type].index('rightscale')
            type = get_resource_type(response.headers[:content_type])
            SingleResource.process(self, JSON.parse(response), type, path)
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

  # Given a path returns a RightApiClient::SingleResource instance.
  #
  def resource(path,params={})
    SingleResource.process(self, *do_get(path,params))
  end

  # This is need for resources like tags where the api/tags/ call is not supported.
  # This will define a dummy object and its methods
  # class DummyResource
  #     include Helper
  #     # path is the base_resource's href
  #     # params is a hash where:
  #     #  key = method name
  #     #  value = action that is needed (like do_post, do_get...)
  #     def initialize(client, path, params={})
  #       params.each do |meth, action|
  #         define_instance_method(meth) do |*args|
  #           # do_get does not return a resource object (unlike do_post)
  #           if meth == :instancesjhjhjgjhghghfhvhjfjfghjgf  
  #             path = path.to_str + add_id_to_path("/instances", *args)
  #             DummyResource.process(client, path, {:live_tasks => 'do_get'})
  #           elsif meth == :live_tasks
  #             Resource.process(client, *client.do_get(path.to_str + '/live/tasks', *args))
  #           elsif action == 'do_get'
  #             Resource.process(client, *client.do_get(path.to_str + '/' + meth.to_s, *args))
  #           elsif meth == :create
  #             client.send action, path, *args
  #           else
  #             # send converts action (a string) into a method call
  #             client.send action, (path.to_str + '/' + meth.to_s), *args
  #           end
  #         end
  #       end
  #     end
  #   end
  
  
  # This class defines the different resource types and the methods that one can call on them
  # This class dynamically adds methods and properties to instances depending on what type of resource they are.
    # This is a filler class so that we don't always have to do an index before anything else
    # This class gets instantiated when the user calls (for example) client.clouds ... (ie. when you want the generic class: no id present) 
  class ResourceType
    include Helper
    # These are the actions that you can call on this resource class
    RESOURCE_TYPE_ACTIONS = {
      :create => [:deployments, :server_arrays, :servers, :ssh_keys, :volumes, :volume_snapshots, :volume_attachments],
      :no_index => [:tags, :tasks]    # Easier to specify the resources that don't need an index call
    }
    
    # Some resources have methods that operate on the resource type itself and not on a particular one (ie: without specifing an id). Place these here:
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
      # resource_type is what the rel for that link is
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
          SingleResource.process(client, *client.do_get(path, *args))
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
  
  
  # Represents a single resource returned by an API call
    # This class once again dynamically adds methods and properties to instances depending on what type of resource they are.
  class SingleResource
    include Helper

    # The API does not provide information about the basic actions that can be
    # performed on a resource so define them here:
    RESOURCE_ACTIONS = {
      :destroy => ['deployment', 'server_array', 'server', 'ssh_key', 'volume', 'volume_snapshot', 'volume_attachment', 'backup'],
      :update => ['deployment', 'instance', 'server_array', 'server', 'backup'],
      :no_show => ['input', 'session', 'tag']  # Once again, easier to define those that don't have a show call associated with them
    }

    # @@ To do
    INSTANCE_RESOURCE_SPECIAL_ACTIONS = {
      :cloud => ['volumes', 'volume_types', 'volume_attachments', 'volume_snapshots', 'instances']
    }
    
    
    attr_reader :client, :attributes, :associations, :actions, :raw, :resource_type

    # Will create a (or an array of) new Resource object(s)
    def self.process(client, data, resource_type)
      if data.kind_of?(Array)  # This is needed for the index call to return an array of all the resources
        data.map { |obj| SingleResource.new(client, obj, resource_type) }
      else
        SingleResource.new(client, data, resource_type)
      end
    end
        
    def inspect
      "#<#{self.class.name} " +
      "resource_type=\"#{@resource_type}\"" +
      "#{', name='+name.inspect if self.respond_to?(:name)}" +
      "#{', resource_uid='+resource_uid.inspect if self.respond_to?(:resource_uid)}>"
    end

    def initialize(client, hash, resource_type)
      @client = client
      @resource_type = resource_type
      @raw = hash.dup
      @attributes, @associations, @actions = Set.new, Set.new, Set.new
      
      links = hash.delete('links') || []
      raw_actions = hash.delete('actions') || []

      # We obviously can't re-define a method called 'self', so pull
      # out the 'self' link and make it 'href'.
      self_index = links.any? && links.each_with_index do |link, idx|
        if link['rel'] == 'self'
          break idx
        end

        if idx == links.size-1
          break nil
        end
      end

      if self_index
        hash['href'] = links.delete_at(self_index)['href']
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
      get_associated_resources(client, links, associations)
      
      
      
      # @@ to do
      INSTANCE_RESOURCE_SPECIAL_ACTIONS[@resource_type].each do |meth, action|
        define_instance_method(meth) do |*args|
          if has_id(*args) # Want to get a single resource. Either doing a show, update, delete...
            SingleResource.process(client, *client.do_get(href, *args))
          else
            #path = add_filters_to_path(hrefs.first, *args)
            ResourceType.new(client, href, meth)
          end
        end
      end if client.instance_token && INSTANCE_RESOURCE_SPECIAL_ACTIONS[@resource_type] 





      # Add destroy method to relevant resources
      if RESOURCE_ACTIONS[:destroy].include?(@resource_type)
        define_instance_method('destroy') do
          client.do_delete(href)
        end
      end

      # Add update method to relevant resources
      if RESOURCE_ACTIONS[:update].include?(@resource_type)
        define_instance_method('update') do |*args|
          client.do_put(href, *args)
        end
      end
      
      # Add show method to relevant resources
      if !RESOURCE_ACTIONS[:no_show].include?(@resource_type)
        define_instance_method('show') do |*args|
          data, resource_type = client.do_get(href, *args)
          data
        end
      end
      
      
      # Some resources are not linked together, so they have to be manually
      # added here.
      case @resource_type
      when 'instance'
        define_instance_method('live_tasks') do |*args|
          SingleResource.process(client, *client.do_get(href + '/live/tasks', *args))
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
                  define_instance_method(k) { SingleResource.process(client, v, 'instance', child_href) }
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

