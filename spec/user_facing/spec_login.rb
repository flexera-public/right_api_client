require File.expand_path('../../../lib/client', __FILE__)

def example_args
  YAML.load_file(File.expand_path('../../../examples/login.yml', __FILE__))
end

def example_client
  RightApi::Client.new(example_args)
end

