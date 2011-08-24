$:.unshift('../lib')

require 'right_api_client'
require 'yaml'

def example_args
  YAML.load_file(File.join(
    File.dirname(__FILE__), '../examples/login.yml'))
end

def example_instance_args
  YAML.load_file(File.join(
    File.dirname(__FILE__), '../examples/instance_login.yml'))
end

def example_client
  RightApi::Client.new(example_args)
end

def example_instance_client
  RightApi::Client.new(example_instance_args)
end
