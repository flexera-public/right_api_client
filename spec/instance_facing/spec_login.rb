require File.expand_path('../../../lib/client', __FILE__)

def example_instance_args
  YAML.load_file(File.expand_path('../../../examples/instance_login.yml', __FILE__))
end

def example_instance_client
  RightApi::Client.new(example_instance_args)
end
