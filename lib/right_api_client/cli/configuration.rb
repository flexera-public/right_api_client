require 'yaml'

# Configuration object for the command-line interface. This is mostly a wrapper around a YML
# config file that lives under the user's home dir (or elsewhere)
class RightApi::CLI::Configuration
  # Default config file directory
  DEFAULT_LOCATION = "~/.right_api_client"

  # Full pathname of default config file
  DEFAULT_PATH     = File.join(DEFAULT_LOCATION, "v#{RightApi::Client::API_VERSION}.yml")

  # Dummy configuration file that is written as an example when none exists
  EXAMPLE_CONFIG   = <<EOS
# This is a sample configuration file for the right_api_client command-line interface (CLI).
# Customize these values
---
:api_url: https://us-3.rightscale.com
:email: user@example.com
:password: secret123
EOS

  attr_reader :path, :keys

  def initialize(path=DEFAULT_PATH)
    @path = File.expand_path(path)
    @keys = YAML.load(File.read(@path))
  end

  def self.write_example(path=DEFAULT_PATH)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') do |f|
      f.write EXAMPLE_CONFIG
    end
  end
end