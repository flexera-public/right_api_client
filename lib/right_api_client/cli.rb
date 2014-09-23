module RightApi
  # Command-line interface for RightApi::Client.
  class CLI
    def initialize(opts={})
      @config = Configuration.new()
      @client = RightApi::Client.new(@config.keys.merge(:skip_login => true, :api_version => 1.5))
    rescue Errno::ENOENT => e
      puts "FATAL: cannot load configuration file"
      Configuration.write_example
      puts "An example has been created, but needs to be customized before you use the CLI."
      puts "Please edit this file: #{Configuration::DEFAULT_PATH}"
    rescue RestClient::Exception => e
      puts "FATAL: cannot construct RightApi::Client object: #{e.http_code} - #{e.http_body}"
      raise ArgumentError, "Fatal error while performing login; make sure authentication credentials are valid!"
    rescue Exception => e
      puts "FATAL: cannot construct RightApi::Client object: #{e.class.name} - #{e.message}"
      raise
    end

    # Enter an IRB console
    def console
      require 'irb'
      IRB.setup nil
      IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context

      require 'irb/ext/multi-irb'
      IRB.irb(nil, @client)
    end
  end
end

require 'right_api_client/cli/configuration'
