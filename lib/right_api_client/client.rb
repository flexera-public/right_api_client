# Design Decisions:
# 
# In the code, we only hard code CRUD operations for resources. We use the .show and .index methods to make the client more efficient. Since it dynamically creates methods it needs to query the API at times. The .show and the .index make it explicit that querying needs to take place. Without them a GET would have to be queried every step of the way. (ie: the index call would be client.deployments, and the create call would be client.deployments.create which would first do an index call).
# 
# 
# 
# Special Cases:
# 
# 
# Special case: Returning resource_types that are not actual API resources:
#  * tags:
#     - by_resource, by_tag  : both return a COLLECTION of resource_type = RESOURCE_TAG
#        . no show or index is defined for that resource_type, therefore return a collection of ResourceDetail objects
#        
#  * data:
#    - querying .data for monitoring_metrics:
#         . no show is defined for that resource_type, therefore return a ResourceDetail object 
# 
# 
# 
# 
# Special case: index call does not act like an index call
#  * session:
#    - session.index should act like a show call and not like an index call (since you cannot query show): therefore it should return a ResourceDetail object
#   
# 
#  * inputs
#    - inputs.index cannot return a collection of Resource objects since .show is not allowed:  therefore it should return a collection of ResourceDetail object
# 
# 
# 
# 
# Special case: Having a resource_type that cannot be accurately determined from the URL:
#  * In server_arrays show: resource_type = current_instance(s) (although it should be instance(s))
#  * In multi_cloud_images show: resource_type = setting(s) (although it should be multi_cloud_image_setting)
#  * Put these in: INCONSISTENT_RESOURCE_TYPES
# 
# 
# 
# Special case: method defined on the generic resource_type itself
#   * 'instances' => {:multi_terminate => 'do_post', :multi_run_executable => 'do_post'},
#   * 'inputs' => {:multi_update => 'do_put'},
#   * 'tags' => {:by_tag => 'do_post', :by_resource => 'do_post', :multi_add => 'do_post', :multi_delete =>'do_post'},
#   * 'backups' => {:cleanup => 'do_post'}
#   * Put these in RESOURCE_TYPE_SPECIAL_ACTIONS
# 
# 
# Special case: resources are not linked together
#   * In ResourceDetail resource_type = Instance, need live_tasks as a method
#     
#     
#     
# Note:
#  * In general, when a new API resource is added you need to indicate in the Client whether index, show, create, update and delete methods are allowed for that resource

require 'rest_client' # rest_client 1.6.1
require 'json'
require 'set'
require 'cgi'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'version'
require 'helper'
require 'resource'
require 'resource_detail'
require 'resources'


# RightApiClient has the generic get/post/delete/put calls that are used
# by resources
module RightApi
  class Client

    ROOT_RESOURCE = '/api/session'
    ROOT_INSTANCE_RESOURCE = '/api/session/instance'

    # permitted parameters for initializing
    AUTH_PARAMS = %w(email password account_id api_url api_version cookies instance_token)
  
    include RightApiHelper

    # The cookies for our client.
    attr_reader :cookies, :instance_token

    def initialize(args)

      # Default params
      @api_url, @api_version = 'https://my.rightscale.com', API_VERSION
      
      # Initializing all instance variables from hash
      args.each { |key,value|
        instance_variable_set("@#{key}", value) if value && AUTH_PARAMS.include?(key.to_s)
      } if args.is_a? Hash

      raise 'This API client is only compatible with RightScale API 1.5 and upwards.' if (Float(@api_version) < 1.5)
      @client = RestClient::Resource.new(@api_url)

      # There are three options for login: credentials, instance token, or if the user already has the cookies they can just use those
      @cookies ||= login()

      if @instance_token
        # Add in the top level links for instance_facing_calls here:
        
        resource_type, path, data = self.do_get(ROOT_INSTANCE_RESOURCE)
        # The instance's href. get_href_from_links is read only
        instance_href = get_href_from_links(data['links'])
        cloud_href = instance_href.split('/instances')[0]

        define_instance_method(:get_instance) do |*params|
          type, instance_path, instance_data = self.do_get(ROOT_INSTANCE_RESOURCE)
          RightApi::ResourceDetail.new(self, type, instance_path, instance_data)
        end

        [:volumes, :volume_attachments, :volume_snapshots, :volume_types].each do |meth|
          define_instance_method(meth) do |*args|
            obj_path = cloud_href + '/' + meth.to_s
            if has_id(*args)
              # add_id_and_params_to_path will modify args
              obj_path = add_id_and_params_to_path(obj_path, *args)
              RightApi::Resource.process(self, get_singular(meth), obj_path)
            else
              # Don't allow users to specify filters here (users need to specify the filters in
              # the index call itself.)
              RightApi::Resources.new(self, obj_path, meth.to_s)
            end
          end
        end
        
        define_instance_method(:live_tasks) do |*args|
          obj_path = instance_href + '/live/tasks'
          if has_id(*args) # can only call this with an id
            obj_path = add_id_and_params_to_path(obj_path, *args)
            RightApi::Resource.process(self, 'live_task', obj_path)
          end
        end

        define_instance_method(:backups) do |*args|
          obj_path = '/api/backups'
          if has_id(*args)
              obj_path = add_id_and_params_to_path(obj_path, *args)
              RightApi::Resource.process(self, 'backup', obj_path)
          else
              RightApi::Resources.new(self, obj_path, 'backups')
          end
        end
      else 
        # Not an instance-facing-call: 
        # Session is the root resource that has links to all the base resources
        define_instance_method(:session) do |*params|
          RightApi::Resources.new(self, ROOT_RESOURCE, 'session')
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

      response = @client[path].post(params, 'X_API_VERSION' => @api_version) do |response, request, result|
        case response.code
        when 302
          response
        else
          response.return!(request, result)
        end
      end
      response.cookies
    end

    # Returns the request headers
    def headers
      {'X_API_VERSION' => @api_version, :cookies => @cookies, :accept => :json}
    end

    # Generic get
    # params are NOT read only
    def do_get(path, params={})
      # Resource id is a special param as it needs to be added to the path
      path = add_id_and_params_to_path(path, params)

      begin
        # Return content type so the resulting resource object knows what kind of resource it is.
        resource_type, body = @client[path].get(headers) do |response, request, result|
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
        @client[path].post(params, headers) do |response, request, result|
          case response.code
          when 201, 202
            # Create and return the resource
            href = response.headers[:location]
            relative_href = href.split(@api_url)[-1]
            # Return the resource that was just created
            # Determine the resource_type from the href: (eg. .../clouds/id).
            # This is based on the assumption that we can determine the resource_type without doing a do_get
            resource_type = get_singular(relative_href.split('/')[-2])
            RightApi::Resource.process(self, resource_type, relative_href)
          when 200..299
            # this is needed for the tags Resource -- which returns a 200 and has a content type
            # therefore, a resource object needs to be returned
            if response.code == 200 && response.headers[:content_type].index('rightscale')
              resource_type = get_resource_type(response.headers[:content_type])
              data = JSON.parse(response)
              # Resource_tag is returned after querrying tags.by_resource or tags.by_tags.
              # You cannot do a show on a resource_tag, but that is basically what we want to do
              data.map { |obj|
                RightApi::ResourceDetail.new(self, resource_type, path, obj)
              }
            else          
              response.return!(request, result)
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
        @client[path].delete(headers) do |response|
          case response.code
          when 200, 204
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
        @client[path].put(params, headers) do |response|
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
  end
end

