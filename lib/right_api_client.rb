require 'rubygems'
# requires rest client 1.6.1
require 'rest_client'
require 'logger'
require 'json'
require 'set'
require 'pp'

RestClient.log = Logger.new(STDOUT)

class RightApiClient
  def initialize(email, password, account_id)
    @email, @password, @account_id = email, password, account_id
    @client = RestClient::Resource.new("https://moo.rightscale.com")
    @cookies = authorize()
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
    content_type, body = @client[path].get(headers.merge('params' => params)) do |response, request, result, &block|
      case response.code
      when 200
        [result.content_type, response.body]
      else
        raise "Wrong response #{response.code.to_s}"
      end
    end

    data = JSON.parse(body)

    [data, content_type]
  end

  def clouds
    Resource.process(self, *do_get('/api/clouds'))
  end

end

class Resource
  attr_reader :client, :attributes, :associations, :actions, :resource_type, :raw

  def self.process(client, data, content_type)
    if data.kind_of?(Array)
      return data.map{|obj| Resource.new(client, obj, content_type) }
    else
      Resource.new(client, data, content_type)
    end
  end

  def inspect
    "#<#{self.class.name} resource_type=\"#{resource_type}\"#{', name='+name.inspect if self.respond_to?(:name)}#{', resource_uid='+resource_uid.inspect if self.respond_to?(:resource_uid)}>"
  end

  def reload
    Resource.process(client, *client.do_get(href))
  end

  def define_instance_method(meth, &blk)
    (class << self; self; end).module_eval do
      define_method(meth, &blk)
    end
  end

  def define_caching_association(meth, &blk)
    define_instance_method(meth) do |*args|
      view = args.first || 'default'
      view = view.to_s
      instance_variable_get("@#{meth.to_s}_#{view}") || instance_variable_set("@#{meth.to_s}_#{view}", blk.call(*args))
    end
  end

  def initialize(client, hash, content_type)
    @client = client
    @content_type = content_type
    @raw = hash
    @attributes, @associations, @actions = Set.new, Set.new, Set.new
    links = hash.delete('links') || []
    raw_actions = hash.delete('actions') || []

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

    raw_actions.each do |action|
      action_name = action['rel']
      actions << action_name.to_sym

      define_instance_method(action_name) do
        raise "need to implement actions"
      end
    end

    links.each do |link|
      associations << link['rel'].to_sym

      define_caching_association(link['rel']) do |*args|
        view = args.first || :default
        Resource.process(client, *client.do_get(link['href'], :view => view))
      end
    end

    hash.each do |k,v|
      if associations.include?(k.to_sym)
        define_caching_association(k) { Resource.process(client, v, nil) }
      else
        attributes << k.to_sym
        define_instance_method(k) { return v }
      end
    end

    if @content_type
      @resource_type = @content_type.scan(/\.com\.(.*)\+json/)[0][0]
    end

    # the api doesnt tell us what resources are supported by what clouds
    if resource_type =~ /cloud/
      [:instances, :images, :ip_addresses, :volumes].each do |rtype|
        define_caching_association(rtype) do |*args|
          view = args.first || :default
          Resource.process(client, *client.do_get(href + "/#{rtype.to_s}", :view => view))
        end
      end
    end

  end
end

if __FILE__ == $0
  client = RightApiClient.new
  clouds = client.clouds
  instances = clouds.first.instances
end