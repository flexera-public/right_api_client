
require 'yaml'


module ExampleHelper

  def example_args
    YAML.load_file(File.join(
      File.dirname(__FILE__), '../../examples/login.yml'))
  end

  def example_client
    RightApiClient.new(example_args)
  end
end

RSpec.configure do |conf|
  conf.include(ExampleHelper)
end

