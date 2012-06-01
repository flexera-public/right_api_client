
require 'pp'
require 'yaml'

require File.expand_path('../../lib/right_api_client', __FILE__)


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

