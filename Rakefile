require 'rubygems'
require './lib/openstackcompute.rb'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "openstackcompute"
    gemspec.summary = "OpenStack Compute Ruby API"
    gemspec.description = "API Binding for OpenStack Compute"
    gemspec.email = "dan.prince@rackspace.com"
    gemspec.homepage = "https://launchpad.net/ruby-openstack-compute"
    gemspec.authors = ["Dan Prince"]
    gemspec.add_dependency 'json'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

  Rake::TestTask.new(:test) do |t|
    t.pattern = 'test/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test'].comment = "Unit"
