require 'pp'
require 'yaml'

$: << File.expand_path('../../lib', __FILE__)

require 'right_api_client'

RSpec.configure do |config|
  #
  # include helpers

  $config = config

  Dir[File.expand_path('../support/**/*.rb', __FILE__)].each do |path|
    require(path)
  end

  #
  # misc

  config.mock_with :flexmock
end
