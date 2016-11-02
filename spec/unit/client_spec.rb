require File.expand_path('../../spec_helper', __FILE__)

describe RightApi::Client, :unit=>true do
  context 'when the RightScale API misbehaves by sending empty bodies with 200 response' do
    before(:each) do
      given_user_facing_client
      @result = Net::HTTPOK.new('1.1', '200', 'OK')
      @result.set_content_type('application/vnd.rightscale.server+json')
      @request = RestClient::Request.new(:method => 'GET', :headers => {}, :url => '/api/servers/1')
      @response = RestClient::Response.create('', @result, {}, @request)
      flexmock(@rest_client).should_receive(:get).with(Hash, Proc).and_yield(@response, @request, @result)
      flexmock(@rest_client).should_receive(:post).with(Hash, Hash, Proc).and_yield(@response, @request, @result)
    end

    it 'raises an empty body error for a GET' do
      expect { @client.servers(:id => 1).show }.to raise_error(RightApi::EmptyBodyError)
    end

    it 'raises an empty body error for a POST' do
      expect { @client.servers.create }.to raise_error(RightApi::EmptyBodyError)
    end
  end
end
