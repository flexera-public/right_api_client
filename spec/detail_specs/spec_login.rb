
require File.join(File.dirname(__FILE__), '../../lib/right_api_client/client')

def example_args
  YAML.load_file(File.join(
    File.dirname(__FILE__), '../../examples/yellow_login.yml'))
end

def example_client
  RightApi::Client.new(example_args)
end

