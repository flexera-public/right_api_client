
require File.join(File.dirname(__FILE__), '../../lib/right_api_client/client')


def example_instance_args
  YAML.load_file(File.join(
    File.dirname(__FILE__), '../../examples/instance_login.yml'))
end


def example_instance_client
  RightApi::Client.new(example_instance_args)
end
