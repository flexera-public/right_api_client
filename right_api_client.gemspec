require File.expand_path('../lib/right_api_client/version', __FILE__)

Gem::Specification.new do |s|

  s.name = 'right_api_client'
  s.version = RightApi::Client::VERSION
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.authors = [ 'Ali Khajeh-Hosseini' ]
  s.email = [ 'alikhajeh1@gmail.com' ]
  s.homepage = 'http://support.rightscale.com'
  s.summary = 'RightScale API HTTP client'
  s.description = %{
RightScale API HTTP client. Spiders the API to discover its resources on the fly.
  }

  s.files = Dir[
    'Rakefile',
    'lib/*.rb', 'spec/*.rb', 'spec/**/*.rb', '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ]

  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'rest-client', '1.6.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec', '1.3.0'
end
