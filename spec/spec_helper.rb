
require File.join(File.dirname(__FILE__), '../lib/right_api_client')

def example_args
  YAML.load_file(File.join(
    File.dirname(__FILE__), '../examples/login.yml'))
end

def example_instance_args
  YAML.load_file(File.join(
    File.dirname(__FILE__), '../examples/instance_login.yml'))
end

def example_client
  RightApiClient.new(example_args)
end

def example_instance_client
  RightApiClient.new(example_instance_args)
end
