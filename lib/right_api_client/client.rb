$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rest_client' # rest_client 1.6.1
require 'json'
require 'set'
require 'cgi'

require 'helper'
require 'resource'
require 'resource_detail'
require 'resources'


# RightApiClient has the generic get/post/delete/put calls that are used
# by resources
module RightApi
  class Client

    VERSION = '0.20.0'
    ROOT_RESOURCE = '/api/session'
    ROOT_INSTANCE_RESOURCE = '/api/session/instance'

    # permitted parameters for initializing
    AUTH_PARAMS = %w(email password account_id api_url api_version cookies instance_token)
  
    include RightApiHelper

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
        define_instance_method(:get_instance) do |*params|
          RightApi::ResourceDetail.new(self, resource_type, path, data)
        end

        [:volumes, :volume_attachments, :volume_snapshots, :volume_types].each do |meth|
          define_instance_method(meth) do |*args|
            path = cloud_href + '/' + meth.to_s
            if has_id(*args)
              path = add_id_and_params_to_path(path, *args)
              RightApi::Resource.process(self, make_singular(meth), path)
            else
              RightApi::Resources.new(self, path, meth.to_s)
            end
          end
        end
        
        define_instance_method(:live_tasks) do |*args|
          path = instance_href + '/live/tasks'
          if has_id(*args) # can only call this with an id
            path = add_id_and_params_to_path(path, *args)
            RightApi::Resource.process(self, 'live_task', path)
          end
        end

        define_instance_method(:backups) do |*args|
          path = '/api/backups'
          if has_id(*args)
              path = add_id_and_params_to_path(path, *args)
              RightApi::Resource.process(self, 'backup', path)
          else
              RightApi::Resources.new(self, path, 'backups')
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
            RightApi::Resource.process(self, resource_type, relative_href)
          when 200..299
            # this is needed for the tags Resource -- which returns a 200 and has a content type
            # therefore, a resource object needs to be returned
            if response.code == 200 && response.headers[:content_type].index('rightscale')
              resource_type = get_resource_type(response.headers[:content_type])
              data = JSON.parse(response)
              RightApi::Resource.process(self, resource_type, path, data)
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
  end
end

