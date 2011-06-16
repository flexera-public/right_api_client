
require File.join(File.dirname(__FILE__), 'spec_helper')


describe RightApiClient::Resource do

  before(:all) do
    @client = RightApiClient.new(YAML.load_file(File.join(
      File.dirname(__FILE__), '../examples/login.yml')))
  end

  describe '#href' do

    it 'returns the href for the resource' do
      @client.clouds.first.href.should == '/api/clouds/232'
    end
  end
end

