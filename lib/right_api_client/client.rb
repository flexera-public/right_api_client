require 'rest_client'
require 'json'
require 'set'
require 'cgi'

require File.expand_path('../version', __FILE__) unless defined?(RightApi::Client::VERSION)
require File.expand_path('../helper', __FILE__)
require File.expand_path('../resource', __FILE__)
require File.expand_path('../resource_detail', __FILE__)
require File.expand_path('../resources', __FILE__)

# RightApiClient has the generic get/post/delete/put calls that are used by resources
module RightApi
  class Client
    include Helper

    ROOT_RESOURCE = '/api/session'
    ROOT_INSTANCE_RESOURCE = '/api/session/instance'
    DEFAULT_API_URL = 'https://my.rightscale.com'

    # permitted parameters for initializing
    AUTH_PARAMS = %w(email password account_id api_url api_version cookies instance_token)
    attr_reader :cookies, :instance_token

    def initialize(args)
      @api_url, @api_version = DEFAULT_API_URL, API_VERSION
      # Initializing all instance variables from hash
      args.each { |key,value|
        instance_variable_set("@#{key}", value) if value && AUTH_PARAMS.include?(key.to_s)
      } if args.is_a? Hash

      raise 'This API client is only compatible with the RightScale API 1.5 and upwards.' if (Float(@api_version) < 1.5)
      @rest_client = RestClient::Resource.new(@api_url)

      # There are three options for login: credentials, instance token, or if the user already
      # has the cookies they can just use those. See config/login.yml.example for more info.
      @cookies ||= login()

      # Add the top level links for instance_facing_calls
      if @instance_token
        resource_type, path, data = self.do_get(ROOT_INSTANCE_RESOURCE)
        instance_href = get_href_from_links(data['links'])
        cloud_href = instance_href.split('/instances')[0]

        define_instance_method(:get_instance) do |*params|
          type, instance_path, instance_data = self.do_get(ROOT_INSTANCE_RESOURCE)
          RightApi::ResourceDetail.new(self, type, instance_path, instance_data)
        end

        Helper::INSTANCE_FACING_RESOURCES.each do |meth|
          define_instance_method(meth) do |*args|
            obj_path = cloud_href + '/' + meth.to_s
            # Following are special cases that need to over-ride the obj_path
            obj_path = '/api/backups'                if meth == :backups
            obj_path = instance_href + '/live/tasks' if meth == :live_tasks
            if has_id(*args)
              obj_path = add_id_and_params_to_path(obj_path, *args)
              RightApi::Resource.process(self, get_singular(meth), obj_path)
            else
              RightApi::Resources.new(self, obj_path, meth.to_s)
            end
          end
        end
      else
        # Session is the root resource that has links to all the base resources
        define_instance_method(:session) do |*params|
          RightApi::Resources.new(self, ROOT_RESOURCE, 'session')
        end
        # Allow the base resources to be accessed directly
        get_associated_resources(self, session.index.links, nil)
      end
    end

    def to_s
      "#<RightApi::Client>"
    end

    # Log HTTP calls to file (file can be STDOUT as well)
    def log(file)
      RestClient.log = file
    end

    # Users shouldn't need to call the following methods directly

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

      response = @rest_client[path].post(params, 'X_API_VERSION' => @api_version) do |response, request, result|
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
        resource_type, body = @rest_client[path].get(headers) do |response, request, result|
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

      data = JSON.parse(body) # TODO: check type before parsing as JSON
      [resource_type, path, data]
    end

    # Generic post
    def do_post(path, params={})
      begin
        @rest_client[path].post(params, headers) do |response, request, result|
          case response.code
          when 201, 202
            # Create and return the resource
            href = response.headers[:location]
            relative_href = href.split(@api_url)[-1]
            # Return the resource that was just created
            # Determine the resource_type from the href (eg. api/clouds/id).
            # This is based on the assumption that we can determine the resource_type without doing a do_get
            resource_type = get_singular(relative_href.split('/')[-2])
            RightApi::Resource.process(self, resource_type, relative_href)
          when 200..299
            # This is needed for the tags Resource -- which returns a 200 and has a content type
            # therefore, ResourceDetail objects needs to be returned
            if response.code == 200 && response.headers[:content_type].index('rightscale')
              resource_type = get_resource_type(response.headers[:content_type])
              data = JSON.parse(response)
              # Resource_tag is returned after querying tags.by_resource or tags.by_tags.
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
        @rest_client[path].delete(headers) do |response, request, result|
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
        @rest_client[path].put(params, headers) do |response, request, result|
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

