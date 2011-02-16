require 'logger'
require 'set'
require 'cgi'

require 'rubygems'
# requires rest client 1.6.1
require 'rest_client'
require 'json'

RestClient.log = Logger.new(STDOUT)

class RightApiClient
  def initialize(email, password, account_id)
    @email, @password, @account_id = email, password, account_id
    @client = RestClient::Resource.new("https://my.rightscale.com")

    # we authorize up front, but the cookie will eventually expire.
    # there should be something in the get/post methods that rescues
    # and re-authorizes when this occurs.
    @cookies = authorize()

    @debug = false
  end

  def authorize
    params = {
      'email'        => @email,
      'password'     => @password,
      'account_href' => "/api/accounts/#{@account_id}"
    }

    response = @client['api/session'].post(params, 'X_API_VERSION' => 1.5) do |response, request, result, &block|
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
    {'X_API_VERSION' => 1.5, :cookies => @cookies, :accept => :json}
  end

  def do_get(path, params={})
    # Normally you would just pass a hash of query params to RestClient,
    # but unfortunately it only takes them as a hash, and for filtering
    # we need to pass multiple parameters with the same key.
    #
    # The result is that we have to build up the query string manually :/

    filters = params.delete(:filters)

    params_string = params.map{|k,v| "#{k.to_s}=#{CGI::escape(v.to_s)}" }.join('&')

    if filters && filters.any?
      path += "?filter[]=" + filters.map{|f| CGI::escape(f) }.join('&filter[]=')
      path += "&#{params_string}"
    else
      path += "?#{params_string}"
    end

    # We need to return the content type so the resulting 
    # resource object can know what kind of resource it is.
    content_type, body = @client[path].get(headers) do |response, request, result, &block|
      case response.code
      when 200
        [result.content_type, response.body]
      else
        p response.body
        raise "Wrong response #{response.code.to_s}"
      end
    end

    data = JSON.parse(body)

    [data, content_type]
  end

  # just a post that expects a 201 and returns the 'location' header
  def do_create(path, params={})
    @client[path].post(params, headers) do |response, request, result, &block|
      case response.code
      when 201
        response.headers[:location]
      else
        p response.body
        raise "Wrong response #{response.code.to_s}"
      end
    end
  end

  # generic post
  def do_post(path, params={})
    @client[path].post(params, headers) do |response, request, result, &block|
      case response.code
      when 200..299
      else
        p response.headers
        p response.body 
      end
      response.return!(request, result, &block)
    end
  end

  # Some 'root' resources.
  def clouds(params={})
    Resource.process(self, *do_get('/api/clouds', params))
  end

  def deployments(params={})
    Resource.process(self, *do_get('/api/deployments', params))
  end

end

class Resource
  attr_reader :client, :attributes, :associations, :actions, :resource_type, :raw

  # Takes some response data from the API
  # Returns a single Resource object or a collection if there were many
  def self.process(client, data, content_type)
    if data.kind_of?(Array)
      return data.map { |obj| Resource.new(client, obj, content_type) }
    else
      Resource.new(client, data, content_type)
    end
  end

  def inspect
    "#<#{self.class.name} resource_type=\"#{resource_type}\"#{', name='+name.inspect if self.respond_to?(:name)}#{', resource_uid='+resource_uid.inspect if self.respond_to?(:resource_uid)}>"
  end

  # shortcut used to build up the resource object
  # from the api responses.
  def define_instance_method(meth, &blk)
    (class << self; self; end).module_eval do
      define_method(meth, &blk)
    end
  end

  def initialize(client, hash, content_type)
    @client = client
    @content_type = content_type
    @raw = hash.dup
    @attributes, @associations, @actions = Set.new, Set.new, Set.new
    links = hash.delete('links') || []
    raw_actions = hash.delete('actions') || []

    # we obviously can't re-define a method called 'self', so pull
    # out the 'self' link and make it 'self_href', i guess.
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

    attributes << :links
    define_instance_method(:links) { return links }

    # i think all of the actions are POST or PUT except
    # 'monitoring_data' (which i think should be a resource).
    # But API doesn't tell us whether an action is a GET
    # or a POST, so we can't do these dynamically yet...
    raw_actions.each do |action|
      action_name = action['rel']
      actions << action_name.to_sym

      define_instance_method(action_name.to_sym) do |*args|
        href = hash['href'] + "/" + action['rel']
        client.do_post(href,args.first)
      end
    end

    # define methods that query the api
    # for the associated resources
    links.each do |link|
      associations << link['rel'].to_sym

      define_instance_method(link['rel']) do |*args|
        Resource.process(client, *client.do_get(link['href'], *args))
      end
    end

    hash.each do |k,v|
      # it's possible that the data we would have needed to
      # query an associated resource for, was present in the
      # response for this resource, if it was requested with a 'view'.
      #
      # if it's an association, but something by the same name is already
      # present in this data structure, use that instead.
      if associations.include?(k.to_sym)
        define_instance_method(k) { Resource.process(client, v, nil) }
      else
        attributes << k.to_sym
        define_instance_method(k) { return v }
      end
    end

    if @content_type
      @resource_type = @content_type.scan(/\.rightscale\.(.*)\+json/)[0][0]
    end

    # the api doesnt tell us what resources are supported by what clouds yet,
    # so...define stuff here? :/
    if resource_type =~ /cloud/
      [:instances, :images, :ip_addresses, :volumes, :instance_types, :datacenters, :ssh_keys, :security_groups].each do |rtype|
        define_instance_method(rtype) do |*args|
          Resource.process(client, *client.do_get(href + "/#{rtype.to_s}", *args))
        end
      end
    end
  end
  
  # create a server in a deployment.
  # NOTE: only works for a deployment
  def create_server(params={})
    uri = client.do_create(self.href + "/servers", :server => params)
    Resource.process(client, *client.do_get(uri))
  end

end
