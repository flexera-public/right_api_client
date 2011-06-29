# encoding: utf-8

require File.join(File.dirname(__FILE__), 'lib/right_api_client/version')
  # bundler wants absolute path


Gem::Specification.new do |s|

  s.name = 'right_api_client'
  s.version = RightApiClient::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = [ 'Ali Khajeh-Hosseini' ]
  s.email = [ 'alikhajeh1@gmail.com' ]
  s.homepage = 'https://github.com/rightscale/right_api_client/'
  s.rubyforge_project = 'rightaws'
  s.summary = 'RightScale API HTTP client'
  s.description = %{
RightScale API HTTP client. Spiders the API to discover its resources on the fly.
  }

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'Rakefile',
    'lib/**/*.rb', 'spec/**/*.rb', 'test/**/*.rb',
    '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ]

  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'rest-client', '1.6.3'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec', '2.6.0'

  s.require_path = 'lib'
end

