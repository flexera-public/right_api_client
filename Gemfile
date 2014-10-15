source 'https://rubygems.org'

# Runtime dependencies that should appear in the gemspec.
gem 'json', '~> 1.0'
gem 'mime-types', '~> 1.0'
gem 'rest-client', '~> 1.6.7'

# Development dependencies that should appear in the gemspec.
group :development do
  gem 'rake', '0.8.7'
  gem 'rspec', '2.9.0'
  gem 'flexmock', '0.8.7'
  gem 'coveralls', :require => false
end

# Gems used during test and development that should be OMITTED from the gemspec
group :test do
  gem 'ruby-debug',
      :platforms => [:ruby_18]
  gem 'debugger',
      :platforms => [:ruby_19, :ruby_20, :ruby_21]
  gem 'jeweler', '~> 2.0'
end
