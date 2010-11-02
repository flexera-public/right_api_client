require 'rubygems'
require 'rest_client'
require 'logger'
require 'json'
require 'pp'

RestClient.log = Logger.new(STDOUT)

class RightApiClient
  def initialize
    @client = RestClient::Resource.new("https://moo.rightscale.com")
    authorize()
  rescue => e
    pp e.response.body
    raise e
  end

  def authorize
    params = {
      'email'      => 'jake@rightscale.com',
      'password'   => '',
      'account_href' => '/api/accounts/71'
    }

    response = @client['api/session'].post(params, 'X_API_VERSION' => 1.5) do |response, request, result, &block|
      case response.code
      when 302
        response
      else
        response.return!(request, result, &block)
      end
    end

    @cookies = response.cookies
  end

  def headers
    {'X_API_VERSION' => 1.5, :cookies => @cookies, :accept => :json}
  end

  def do_get(path, params={})
    content_type, body = @client[path].get(headers.merge!('params' => params)) do |response, request, result, &block|
      case response.code
      when 200
        [result.content_type, response.body]
      else
        raise "Wrong response #{response.code.to_s}"
      end      
    end

    data = JSON.parse(body)
    if data.kind_of?(Array)
      data.reject!{|obj| obj.nil?}
    end

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

  def initialize(client, hash, content_type)
    @client = client
    @content_type = content_type
    @raw = hash
    @attributes, @associations, @actions = [], [], []
    links = hash.delete('links') || []
    raw_actions = hash.delete('actions') || []

    self_index = links.each_with_index do |link, idx|
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

    singleton = (class << self; self; end)

    attributes << :links
    singleton.module_eval do
      define_method(:links) do
        return links
      end
    end

    raw_actions.each do |action|
      action_name = action['rel']
      actions << action_name.to_sym

      singleton.module_eval do
        define_method(action_name) do
          raise "need to implement actions"
        end
      end
    end

    hash.each do |k,v|
      if v.kind_of?(Array) && v.any? && v.first.kind_of?(Hash)
        associations << k.to_sym

        singleton.module_eval do
          define_method(k) { Resource.process(client, v, nil) }
        end
      else
        attributes << k.to_sym

        singleton.module_eval do
          define_method(k) { return v }
        end
      end
    end

    links.each do |link|
      associations << link['rel'].to_sym

      singleton.module_eval do
        define_method(link['rel']) do
          Resource.process(client, *client.do_get(link['href']))
        end
      end
    end

    @resource_type = @content_type.scan(/\.com\.(.*)\+json/)[0][0]

    # the api doesnt tell us what resources are supported by what clouds
    if resource_type =~ /cloud/
      singleton.module_eval do
        [:instances, :images].each do |rtype|
          define_method(rtype) do
            Resource.process(client, *client.do_get(href + "/#{rtype.to_s}"))
          end
        end
      end
    end

  end
end

if __FILE__ == $0
  client = RightApiClient.new
  clouds = client.clouds
  instances = clouds.first.instances
  begin
    pp client.instances_for_cloud(232).map {|i| Resource.new(client, i) }
  rescue => e
    p e.response.body
  end
end