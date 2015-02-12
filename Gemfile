source 'https://rubygems.org'

# Runtime dependencies that should appear in the gemspec.
gemspec

# Development dependencies that should appear in the gemspec.
group :development do
  gem 'pry'
end

# Gems used during test and development that should be OMITTED from the gemspec
group :test do
  gem 'ruby-debug',
      :platforms => [:ruby_18]
  gem 'debugger',
      :platforms => [:ruby_19, :ruby_20, :ruby_21]
  gem 'jeweler', '~> 2.0'
end
