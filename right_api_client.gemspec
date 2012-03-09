require File.expand_path('../lib/right_api_client/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'right_api_client'
  s.version      = RightApi::Client::VERSION
  s.platform     = Gem::Platform::RUBY
  s.date         = Time.now.utc.strftime("%Y-%m-%d")
  s.require_path = 'lib'
  s.authors      = [ 'RightScale, Inc.' ]
  s.email        = [ 'rubygems@rightscale.com' ]
  s.homepage     = 'https://github.com/rightscale/right_api_client'
  s.summary      = 'RightScale MultiCloud API HTTP Client'
  s.description  = %{
The right_api_client gem simplifies the use of RightScale's MultiCloud API. It provides
a simple object model of the API resources, and handles all of the fine details involved
in making HTTP calls and translating their responses.
  }
  s.files = `git ls-files`.split(' ')
  s.test_files = `git ls-files spec config`.split(' ')
  s.rubygems_version = '1.8.17'

  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'rest-client',      '1.6.7'

  s.add_development_dependency 'rake',         '0.8.7'
  s.add_development_dependency 'rspec',        '1.3.0'
  s.add_development_dependency 'flexmock',     '0.8.7'
  s.add_development_dependency 'simplecov',    '0.4.2'
  s.add_development_dependency 'bundler'
end
