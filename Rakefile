require "rubygems"
require "bundler/setup"


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "to_api"
    gem.rubyforge_project = "to_api"
    gem.summary = %Q{Helper for simplifying JSON api creation}
    gem.description = %Q{Helper for simplifying JSON api creation.}
    gem.email = "shawn42@gmail.com"
    gem.homepage = "http://github.com/atomicobject/to_api"
    gem.authors = ["Shawn Anderson","Ryan Fogle"]
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "jeweler"
    gem.test_files = FileList['{spec,test}/**/*.rb']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


begin
  require 'spec/rake/spectask'
  desc "Run the code examples in spec/"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_files = FileList["spec/**/*_spec.rb"]
  end
  task :default => :spec

rescue LoadError
  puts "RSpec (or a dependency) not available. Install it with: gem install rspec"
end

# vim: syntax=Ruby
