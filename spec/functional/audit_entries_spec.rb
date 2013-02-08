require File.expand_path('../../spec_helper', __FILE__)

describe RightApi::Client do

  before(:all) do

    creds = File.expand_path('../../../config/login.yml', __FILE__)

    begin
      @client = RightApi::Client.new(YAML.load_file(creds))
    rescue Exception => e
      puts "=" * 80
      puts "WARNING: please provide a valid config/login.yml file"
      puts
      puts e.message
      puts "=" * 80
    end

    server_arrays =
      @client.server_arrays.index

    @server_array =
      server_arrays.find { |sa| sa.name.match(/test/i) } ||
      server_arrays.first

    raise "sorry, can't test, no server arrays in your RS" unless @server_array
  end

  describe '#audit_entries' do

    describe '#create' do

      it 'creates audit entries' do

        ae = @client.audit_entries.create(:audit_entry => {
          'auditee_href' => @server_array.href,
          'summary' => "right_api_client test #{$$}-#{Time.now.to_f}",
          'detail' => 'sacrificing goats to make it work'
        })

        ae.class.should == RightApi::Resource
        ae.show.href.should match(/^\/api\/audit_entries\/[a-z0-9]+$/)
      end
    end
  end

  describe 'AuditEntry resource' do

    describe '#detail' do

      it 'returns the detail plain text' do

        ae = @client.audit_entries.create(:audit_entry => {
          'auditee_href' => @server_array.href,
          'summary' => "right_api_client test #{$$}-#{Time.now.to_f}",
          'detail' => "and it's 1984"
        })

        ae.show.detail.show.text.should == "and it's 1984"
      end
    end
  end
end

