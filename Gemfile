source 'https://rubygems.org'

# Use local clones if possible.
def custom_gem(name, options = Hash.new)
  local_path = File.expand_path("../vendor/#{name}", __FILE__)
  if File.exist?(local_path)
    gem name, options.merge(:path => local_path).delete_if { |key, _| [:git, :branch].include?(key) }
  else
    gem name, options
  end
end

group :development do
  gem "rake"
  gem "yard"
  gem "RedCloth", "~> 4.2.9"
  gem "pry"
end

group :test do
  # Should work for either RSpec1 or Rspec2, but you cannot have both at once.
  # Also, keep in mind that if you install Rspec 2 it prevents Rspec 1 from running normally.
  # Unless you use it like 'bundle exec spec spec', that is.

  if RUBY_PLATFORM =~ /mswin|windows|mingw/
    # For color support on Windows (deprecated?)
    gem 'win32console'
    gem 'rspec', '~>1.3.0', :require => 'spec'
  else
    rspec_version = ENV.fetch('RSPEC', '3.1.0')
    gem 'rspec', rspec_version, :require => nil
  end
  gem 'minitest', :require => nil

  gem "eventmachine"
  gem "cool.io",             :platforms => [:ruby_19, :ruby_20, :ruby_21, :ruby_22]
  custom_gem "amqp", :git => "git://github.com/ruby-amqp/amqp.git", :branch => "master"
end
