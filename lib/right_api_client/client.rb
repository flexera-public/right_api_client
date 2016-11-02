require 'rest_client'
require 'json'
require 'set'
require 'cgi'
require 'base64'
require 'rbconfig'

require File.expand_path('../version', __FILE__) unless defined?(RightApi::Client::VERSION)
require File.expand_path('../helper', __FILE__)
require File.expand_path('../resource', __FILE__)
require File.expand_path('../resource_detail', __FILE__)
require File.expand_path('../resources', __FILE__)
require File.expand_path('../errors', __FILE__)
require File.expand_path('../exceptions', __FILE__)

# This is used to extend a temporary local copy of the client during login.
# It overrides the post functionality, which in turn creates a new instance of RestClient::Request
#   which is then extended to override log_request to keep creds from getting into our logs.
module PostOverride
  def post(payload, additional_headers={}, &block)
    headers = (options[:headers] || {}).merge(additional_headers)
    requestor =  ::RestClient::Request.new(options.merge(
      :method => :post,
      :url => url,
      :payload => payload,
      :headers => headers)
    )
    requestor.extend(LogOverride)
    requestor.execute(&block)
  end
end

# This is used to extend a new instance of RestClient::Request and override it's log_request.
# Override version keeps email/password from getting into the logs.
module LogOverride
  def log_request
   if RestClient.log
      out = []
      out << "RestClient.#{method} #{url.inspect}"
      if !payload.nil?
        if (payload.short_inspect.include? "email") || (payload.short_inspect.include? "password")
          out << "<hidden credentials>"
        else
          out <<  payload.short_inspect
        end
      end
      out << processed_headers.to_a.sort.map { |(k, v)| [k.inspect, v.inspect].join("=>") }.join(", ")
      RestClient.log << out.join(', ') + "\n"
    end
  end
end

# RightApiClient has the generic get/post/delete/put calls that are used by resources
module RightApi
  class Client
    include Helper

    DEFAULT_OPEN_TIMEOUT = nil
    DEFAULT_TIMEOUT = 6 * 60
    DEFAULT_MAX_ATTEMPTS = 5

    DEFAULT_SSL_VERSION = 'TLSv1'

    ROOT_RESOURCE  = '/api/session'
    OAUTH_ENDPOINT = '/api/oauth2'
    ROOT_INSTANCE_RESOURCE = '/api/session/instance'
    DEFAULT_API_URL = 'https://my.rightscale.com'

    # permitted parameters for initializing
    AUTH_PARAMS = %w[
      email password_base64 password
      instance_token
      refresh_token access_token
      cookies
      account_id api_url api_version
      timeout open_timeout max_attempts
      enable_retry rest_client_class
      rl10
    ]

    # @return [String] OAuth 2.0 refresh token if provided
    attr_reader :refresh_token

    # @return [String] OAuth 2.0 access token, if present
    attr_reader :access_token

    # @return [Time] expiry timestamp for OAuth 2.0 access token
    attr_reader :access_token_expires_at

    attr_accessor :account_id

    # @return [String] Base API url, e.g. https://us-3.rightscale.com
    attr_accessor :api_url

    # @return [String] instance API token as included in user-data
    attr_reader :instance_token

    # @return [Hash] collection of API cookies
    # @deprecated please use OAuth 2.0 refresh tokens instead of password-based authentication
    attr_reader :cookies

    # @return [Hash] debug information about the last request and response
    attr_reader :last_request

    # @return [Integer] number of seconds to wait for socket open
    attr_reader :open_timeout

    # @return [Integer] number of seconds to wait for API response
    attr_reader :timeout

    # @return [Integer] number of times to retry idempotent requests (iff enable_retry == true)
    attr_reader :max_attempts

    # @return [Boolean] whether to retry idempotent requests that fail
    attr_reader :enable_retry

    # Instantiate a new Client, then login if necessary.
    def initialize(args)
      raise 'This API client is only compatible with Ruby 1.8.7 and upwards.' if (RUBY_VERSION < '1.8.7')

      @api_url, @api_version = DEFAULT_API_URL, API_VERSION
      @open_timeout, @timeout, @max_attempts = DEFAULT_OPEN_TIMEOUT, DEFAULT_TIMEOUT, DEFAULT_MAX_ATTEMPTS
      @ssl_version = DEFAULT_SSL_VERSION
      @enable_retry = false

      # Initializing all instance variables from hash
      args.each { |key,value|
        instance_variable_set("@#{key}", value) if AUTH_PARAMS.include?(key.to_s)
      } if args.is_a? Hash

      raise 'This API client is only compatible with the RightScale API 1.5 and upwards.' if (Float(@api_version) < 1.5)

      # If rl10 parameter was passed true, read secrets file to set @local_token, and @api_url
      if @rl10
        case RbConfig::CONFIG['host_os']
        when /mswin|mingw|cygwin/
          local_secret_file = File.join(ENV['ProgramData'] || 'C:/ProgramData', 'RightScale/RightLink/secret')
        else
          local_secret_file = '/var/run/rightlink/secret'
        end
        local_auth_info = Hash[File.readlines(local_secret_file).map{ |line| line.chomp.split('=', 2) }]
        @local_token = local_auth_info['RS_RLL_SECRET']
        @api_url = "http://localhost:#{local_auth_info['RS_RLL_PORT']}"
      end

      # allow a custom resource-style REST client (for special logging, etc.)
      @rest_client_class ||= ::RestClient::Resource
      @rest_client = @rest_client_class.new(@api_url, :open_timeout => @open_timeout, :timeout => @timeout, :ssl_version => @ssl_version)
      @last_request = {}

      # There are five options for login:
      #  - user email/password (using plaintext or base64-obfuscated password)
      #  - user OAuth refresh token
      #  - instance API token
      #  - existing user-supplied cookies
      #  - existing user-supplied OAuth access token
      #
      # The latter two options are not really login; they imply that the user logged in out of band.
      # See config/login.yml.example for more info.
      login() if need_login?

      timestamp_cookies

      # Add the top level links for instance_facing_calls
      if @instance_token || @local_token
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
            obj_path = '/api/tags'                   if meth == :tags
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
      api_host = URI.parse(api_url).host.split('.').first rescue 'unknown'
      "#<RightApi::Client host=#{api_host} account=#{@account_id}>"
    end

    alias inspect to_s

    # Log HTTP calls to file (file can be STDOUT as well)
    def log(file)
      RestClient.log = file
    end

    # Given a path returns a RightApiClient::Resource instance.
    #
    def resource(path, params={})
      r = Resource.process_detailed(self, *do_get(path, params))

      # note that process_detailed will make a best-effort to return an already
      # detailed resource or array of detailed resources but there may still be
      # legacy cases where #show is still needed. calling #show on an already
      # detailed resource is a no-op.
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
          # Session is expired or invalid
          login()
          retry
        else
          raise e
        end
      end
    end

    def login
      account_href = "/api/accounts/#{@account_id}"

      params, path =
      if @refresh_token
        [ {'grant_type' => 'refresh_token',
           'refresh_token'=>@refresh_token},
          OAUTH_ENDPOINT ]
      elsif @instance_token
          [ { 'instance_token' => @instance_token,
              'account_href' => account_href },
            ROOT_INSTANCE_RESOURCE ]
      elsif @password_base64
        [ { 'email' => @email,
            'password' => Base64.decode64(@password_base64),
            'account_href' => account_href },
          ROOT_RESOURCE ]
      else
        [ { 'email' => @email,
            'password' => @password,
            'account_href' => account_href },
          ROOT_RESOURCE ]
      end

      response = nil
      attempts = 0
      begin
        response = @rest_client[path].extend(PostOverride).post(params, 'X-Api-Version' => @api_version) do |response, request, result, &block|
          if [301, 302, 307].include?(response.code)
            update_api_url(response)
            response = @rest_client[path].extend(PostOverride).post(params, 'X-Api-Version' => @api_version)
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

      if path == OAUTH_ENDPOINT
        update_access_token(response)
      else
        update_cookies(response)
      end
    end

    # Returns the request headers
    def headers
      h = {
        'X-Api-Version' => @api_version,
        :accept => :json,
      }

      if @account_id
        h['X-Account'] = @account_id
      end

      if @access_token
        h['Authorization'] = "Bearer #{@access_token}"
      elsif @cookies
        h[:cookies] = @cookies
      end

      if @local_token
        h['X-RLL-Secret'] = @local_token
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
      login if need_login?

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
              elsif result.content_type.index('text/plain')
                'text'
              else
                ''
              end

              # work around getting ASCII-8BIT from some resources like audit entry detail
              charset = get_charset(response.headers)
              if charset && response.body.encoding != charset
                response.body.force_encoding(charset)
              end

              # raise an error if the API is misbehaving and returning an empty response when it shouldn't
              if type != 'text' && response.body.empty?
                raise EmptyBodyError.new(request, response)
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
      login if need_login?

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
                # raise an error if the API is misbehaving and returning an empty response when it shouldn't
                raise EmptyBodyError.new(request, response) if response.body.empty?
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
      login if need_login?

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
            when 200, 204
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
      login if need_login?

      params = fix_array_of_hashes(params)

      req, res, resource_type, body = nil

      # Altering headers to set Content-Type to text/plain when updating rightscript content
      put_headers = path =~ %r(^/api/right_scripts/.+/source$) ? headers.merge('Content-Type' => 'text/plain') : headers

      begin
        retry_request do
          @rest_client[path].put(params, put_headers) do |response, request, result|
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

    # Determine whether the client should login based on known state of cookies/tokens and their
    # expiration timestamps.
    #
    # If the method returns true, then the client MUST login based on known state.
    #
    # If the method returns false, login MAY still be required; we simply cannot determine with
    # confidence that login is required. This can happen in the following cases:
    #   - cookie jar has cookies, but they are expired, corrupted or unrelated to auth
    #   - #initialize method received an access_token but no access_token_expires_at
    #
    # @return [Boolean] true if re-login is known to be required
    def need_login?
      # @local_token is the key to use the local proxy.  Connecting using this key
      # and the local proxy does not require login.
      if @local_token
        false
      elsif @access_token
        # If our access token is expired and we know it...
        @access_token_expires_at && @access_token_expires_at - Time.now < 900
      elsif @cookies
        # Or if we have a cookie jar and it's empty
        @cookies.respond_to?(:empty?) && @cookies.empty?
      else
        # Or if we have neither cookies nor an access token (because how else can a man auth?)
        true
      end
    end

    # Determine whether an exception can be fixed by logging in again.
    #
    # @param e [ApiError] the exception to check
    #
    # @return [Boolean] true if re-login is appropriate
    #
    def re_login?(e)
      auth_error =
        (e.response_code == 403 && e.message =~ %r(.*cookie is expired or invalid)) ||
        e.response_code == 401

      renewable_creds =
        (@instance_token || (@email && (@password || @password_base64)) || @refresh_token)

      auth_error && renewable_creds
    end

    # @param [String] content_type an HTTP Content-Type header
    # @return [String] the resource_type associated with content_type
    def get_resource_type(content_type)
      content_type.scan(/\.rightscale\.(.*)\+json/)[0][0]
    end

    # @param [Hash{Symbol => String}] headers the HTTP headers
    def get_charset(headers)
      charset = headers[:content_type].split(';').map(&:strip).detect { |item| item =~ /^charset=/i }
      if charset
        Encoding.find(charset.gsub(/^charset=/i, ''))
      end
    end

    # Makes sure the @cookies have a timestamp.
    #
    def timestamp_cookies
      return unless @cookies

      class << @cookies; attr_accessor :timestamp; end
      @cookies.timestamp = Time.now
    end

    # Sets the @access_token and @access_token_expires_at
    #
    def update_access_token(response)
      h = JSON.load(response)
      @access_token = String(h['access_token'])
      @access_token_expires_at = Time.at(Time.now.to_i + Integer(h['expires_in']))
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

      # note that the legacy code did not use the proper timeout values upon
      # redirect (i.e. always set :timeout => -1) but that seems like an
      # oversight; always use configured timeout values regardless of redirect.
      @rest_client = @rest_client_class.new(
        @api_url, :open_timeout => @open_timeout, :timeout => @timeout, :ssl_version => @ssl_version)
    end
  end
end

