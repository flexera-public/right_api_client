require 'jeweler'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern= 'spec/**/*_spec.rb'
end

tasks = Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification; see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = 'right_api_client'
  gem.homepage = 'https://github.com/rightscale/right_api_client'
  gem.license = 'MIT'
  gem.summary = 'RightScale MultiCloud API HTTP Client'
  gem.description = %{
The right_api_client gem simplifies the use of RightScale's MultiCloud API.
It provides a simple object model of the API resources, and handles all of the
fine details involved in making HTTP calls and translating their responses.
}
  gem.email = 'rubygems@rightscale.com'
  gem.authors = ['RightScale, Inc.']

  # This gem is special; its own VERSION file needs to be shipped with the gem in order to
  # initialize the VERSION constant living under RightApi::Client.
  gem.files.include 'VERSION'

  # Keep the gem nice and svelte
  gem.files.exclude 'config'
  gem.files.exclude 'spec'
end

# Never auto-commit during operations that change the repository. Allows developers to decide on their own commit comment
# and/or aggregate version bumps into other fixes.
tasks.jeweler.commit = false

Jeweler::RubygemsDotOrgTasks.new

CLEAN.include('pkg')
