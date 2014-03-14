require 'rest_client'
require 'json'
require 'set'
require 'cgi'
require 'base64'

require File.expand_path('../version', __FILE__) unless defined?(RightApi::Client::VERSION)
require File.expand_path('../helper', __FILE__)
require File.expand_path('../resource', __FILE__)
require File.expand_path('../resource_detail', __FILE__)
require File.expand_path('../resources', __FILE__)
require File.expand_path('../errors', __FILE__)

# RightApiClient has the generic get/post/delete/put calls that are used by resources
module RightApi
  class Client
    include Helper

    DEFAULT_OPEN_TIMEOUT = nil
    DEFAULT_TIMEOUT = -1
    DEFAULT_MAX_ATTEMPTS = 5

    ROOT_RESOURCE = '/api/session'
    ROOT_INSTANCE_RESOURCE = '/api/session/instance'
    DEFAULT_API_URL = 'https://my.rightscale.com'

    # permitted parameters for initializing
    AUTH_PARAMS = %w[
      email password_base64 password account_id api_url api_version
      cookies instance_token access_token timeout open_timeout max_attempts enable_retry
    ]

    attr_reader :cookies, :instance_token, :access_token, :last_request, :timeout, :open_timeout, :max_attempts, :enable_retry
    attr_accessor :account_id, :api_url

    def initialize(args)

      raise 'This API client is only compatible with Ruby 1.8.7 and upwards.' if (RUBY_VERSION < '1.8.7')

      @api_url, @api_version = DEFAULT_API_URL, API_VERSION
      @open_timeout, @timeout, @max_attempts = DEFAULT_OPEN_TIMEOUT, DEFAULT_TIMEOUT, DEFAULT_MAX_ATTEMPTS
      @enable_retry = false

      # Initializing all instance variables from hash
      args.each { |key,value|
        instance_variable_set("@#{key}", value) if value && AUTH_PARAMS.include?(key.to_s)
      } if args.is_a? Hash

      raise 'This API client is only compatible with the RightScale API 1.5 and upwards.' if (Float(@api_version) < 1.5)

      @rest_client = RestClient::Resource.new(@api_url, :open_timeout => @open_timeout, :timeout => @timeout)
      @last_request = {}

      # There are four options for login:
      #  - credentials
      #  - instance API token
      #  - existing user-supplied cookies
      #  - existing user-supplied OAuth access token
      #
      # The latter two options are not really login; they imply that the user logged in out of band.
      # See config/login.yml.example for more info.
      login() unless @cookies || @access_token

      timestamp_cookies

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

    # Given a path returns a RightApiClient::Resource instance.
    #
    def resource(path, params={})

      r = Resource.process(self, *do_get(path, params))

      r.respond_to?(:show) ? r.show : r
    end

    # Seems #resource tends to expand (call index) on Resources instances,
    # so this is a workaround.
    #
    def resources(type, path)

      Resources.new(self, path, type)
    end

    protected
    # Users shouldn't need to call the following methods directly

    def retry_request(is_read_only = false)
      attempts = 0
      begin
        yield
      rescue OpenSSL::SSL::SSLError => e
        raise e unless @enable_retry
        # These errors pertain to the SSL handshake.  Since no data has been
        # exchanged its always safe to retry
        raise e if attempts >= @max_attempts
        attempts += 1
        retry
      rescue Errno::ECONNRESET, RestClient::ServerBrokeConnection, RestClient::RequestTimeout => e
        raise e unless @enable_retry
        #   Packetloss related.
        #   There are two timeouts on the ssl negotiation and data read with different
        #   times. Unfortunately the standard timeout class is used for both and the
        #   exceptions are caught and reraised so you can't distinguish between them.
        #   Unfortunate since ssl negotiation timeouts should always be retryable
        #   whereas data may not.
        if is_read_only
          raise e if attempts >= @max_attempts
          attempts += 1
          retry
        else
          raise e
        end
      rescue ApiError => e
        if re_login?(e)
          # Session cookie is expired or invalid
          login()
          retry
        else
          raise e
        end
      end
    end

    def login
      params, path = if @instance_token
        [ { 'instance_token' => @instance_token },
          ROOT_INSTANCE_RESOURCE ]
      elsif @password_base64
        [ { 'email' => @email, 'password' => Base64.decode64(@password_base64) },
          ROOT_RESOURCE ]
      else
        [ { 'email' => @email, 'password' => @password },
          ROOT_RESOURCE ]
      end
      params['account_href'] = "/api/accounts/#{@account_id}"

      response = nil
      attempts = 0
      begin
        response = @rest_client[path].post(params, 'X-Api-Version' => @api_version) do |response, request, result, &block|
          if response.code == 302
            update_api_url(response)
            response.follow_redirection(request, result, &block)
          else
            response.return!(request, result)
          end
        end
      rescue Errno::ECONNRESET, RestClient::RequestTimeout, OpenSSL::SSL::SSLError, RestClient::ServerBrokeConnection
        raise unless @enable_retry
        raise if attempts >= @max_attempts
        attempts += 1
        retry
      end

      update_cookies(response)
    end

    # Returns the request headers
    def headers
      h = {
        'X-Api-Version' => @api_version,
        'X-Account' => @account_id,
        :accept => :json,
      }

      if @access_token
        h['Authorization'] = "Bearer #{@access_token}"
      elsif @cookies
        h[:cookies] = @cookies
      end

      h
    end

    def update_last_request(request, response)
      @last_request[:request]  = request
      @last_request[:response] = response
    end

    # Generic get
    # params are NOT read only
    def do_get(path, params={})

      # Resource id is a special param as it needs to be added to the path
      path = add_id_and_params_to_path(path, params)

      req, res, resource_type, body = nil

      begin
        retry_request(true) do
          # Return content type so the resulting resource object knows what kind of resource it is.
          resource_type, body = @rest_client[path].get(headers) do |response, request, result, &block|
            req, res = request, response
            update_cookies(response)
            update_last_request(request, response)

            case response.code
            when 200
              # Get the resource_type from the content_type, the resource_type
              # will be used later to add relevant methods to relevant resources
              type = if result.content_type.index('rightscale')
                get_resource_type(result.content_type)
              else
                ''
              end

              [type, response.body]
            when 301, 302
              update_api_url(response)
              response.follow_redirection(request, result, &block)
            when 404
              raise UnknownRouteError.new(request, response)
            else
              raise ApiError.new(request, response)
            end
          end
        end
      rescue => e
        raise wrap(e, :get, path, params, req, res)
      end

      data = if resource_type == 'text'
        { 'text' => body }
      else
        JSON.parse(body, :allow_nan => true)
      end

      [resource_type, path, data]
    end

    # Generic post
    def do_post(path, params={})
      params = fix_array_of_hashes(params)

      req, res, resource_type, body = nil

      begin
        retry_request do
          @rest_client[path].post(params, headers) do |response, request, result|
            req, res = request, response
            update_cookies(response)
            update_last_request(request, response)

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
            when 204
              nil
            when 200..299
              # This is needed for the tags Resource -- which returns a 200 and has a content type
              # therefore, ResourceDetail objects needs to be returned
              if response.code == 200 && response.headers[:content_type].index('rightscale')
                resource_type = get_resource_type(response.headers[:content_type])
                data = JSON.parse(response, :allow_nan => true)
                # Resource_tag is returned after querying tags.by_resource or tags.by_tags.
                # You cannot do a show on a resource_tag, but that is basically what we want to do
                data.map { |obj|
                  RightApi::ResourceDetail.new(self, resource_type, path, obj)
                }
              else
                response.return!(request, result)
              end
            when 301, 302
              update_api_url(response)
              do_post(path, params)
            when 404
              raise UnknownRouteError.new(request, response)
            else
              raise ApiError.new(request, response)
            end
          end
        end
      rescue ApiError => e
        raise wrap(e, :post, path, params, req, res)
      end
    end

    # Generic delete
    def do_delete(path, params={})
      # Resource id is a special param as it needs to be added to the path
      path = add_id_and_params_to_path(path, params)

      req, res, resource_type, body = nil

      begin
        retry_request do
          @rest_client[path].delete(headers) do |response, request, result|
            req, res = request, response
            update_cookies(response)
            update_last_request(request, response)

            case response.code
            when 200
            when 204
              nil
            when 301, 302
              update_api_url(response)
              do_delete(path, params)
            when 404
              raise UnknownRouteError.new(request, response)
            else
              raise ApiError.new(request, response)
            end
          end
        end
      rescue => e
        raise wrap(e, :delete, path, params, req, res)
      end
    end

    # Generic put
    def do_put(path, params={})
      params = fix_array_of_hashes(params)

      req, res, resource_type, body = nil

      begin
        retry_request do
          @rest_client[path].put(params, headers) do |response, request, result|
            req, res = request, response
            update_cookies(response)
            update_last_request(request, response)

            case response.code
            when 204
              nil
            when 301, 302
              update_api_url(response)
              do_put(path, params)
            when 404
              raise UnknownRouteError.new(request, response)
            else
              raise ApiError.new(request, response)
            end
          end
        end
      rescue => e
        raise wrap(e, :put, path, params, req, res)
      end
    end

    def re_login?(e)
      # cannot successfully re-login with only an access token; we want the
      # expiration error to be raised.
      return false if @access_token
      e.message.index('403') && e.message =~ %r(.*Session cookie is expired or invalid)
    end

    # returns the resource_type
    def get_resource_type(content_type)
      content_type.scan(/\.rightscale\.(.*)\+json/)[0][0]
    end

    # Makes sure the @cookies have a timestamp.
    #
    def timestamp_cookies

      return unless @cookies

      class << @cookies; attr_accessor :timestamp; end
      @cookies.timestamp = Time.now
    end

    # Sets the @cookies (and timestamp it).
    #
    def update_cookies(response)

      return unless response.cookies

      (@cookies ||= {}).merge!(response.cookies)
      timestamp_cookies
    end

    #
    # A helper class for error details
    #
    class ErrorDetails

      attr_reader :method, :path, :params, :request, :response

      def initialize(me, pt, ps, rq, rs)

        @method = me
        @path = pt
        @params = ps
        @request = rq
        @response = rs
      end

      def code

        @response ? @response.code : nil
      end
    end

    # Adds details (path, params) to an error. Returns the error.
    #
    def wrap(error, method, path, params, request, response)

      class << error; attr_accessor :_details; end
      error._details = ErrorDetails.new(method, path, params, request, response)

      error
    end

    private

    def update_api_url(response)
      # Update the rest client url if we are redirected to another endpoint
      uri = URI.parse(response.headers[:location])
      @api_url = "#{uri.scheme}://#{uri.host}"
      @rest_client = RestClient::Resource.new(@api_url, :timeout => -1)
    end
  end
end

