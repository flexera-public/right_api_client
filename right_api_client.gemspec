require File.expand_path('../lib/right_api_client/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'right_api_client'
  s.version      = RightApi::Client::VERSION
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.authors      = [ 'Ali Khajeh-Hosseini' ]
  s.email        = [ 'alikhajeh1@gmail.com' ]
  s.homepage     = 'https://github.com/rightscale/right_api_client'
  s.summary      = 'RightScale MultiCloud API HTTP Client'
  s.description  = %{
The right_api_client gem simplifies the use of RightScale's MultiCloud API. It provides
a simple object model of the API resources, and handles all of the fine details involved
in making HTTP calls and translating their responses.
  }

  s.files = Dir[
    'Rakefile',
    'lib/*.rb', 'lib/**/*.rb', 'spec/*.rb', 'config/login.yml.example',
    'login_to_client_irb.rb',
    '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ]

  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'rest-client',      '1.6.3'
  s.add_development_dependency 'rake',         '0.8.7'
  s.add_development_dependency 'bundler',
  s.add_development_dependency 'rspec',        '1.3.0'
  s.add_development_dependency 'flexmock',     '0.8.7'
  s.add_development_dependency 'ruby-debug19', '0.11.6'
  s.add_development_dependency 'simplecov',    '0.4.2'
end
