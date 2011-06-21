
require File.join(File.dirname(__FILE__), 'spec_helper')


describe RightApiClient::Resource do

  before(:all) do
    @client = example_client
  end

  describe '#href' do

    it 'returns the href for the resource' do
      @client.clouds.first.href.should match(/^\/api\/clouds\//)
    end
  end
end

