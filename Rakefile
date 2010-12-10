require "rubygems"
require "bundler/setup"

begin
  require 'spec/rake/spectask'
  desc "Run the code examples in spec/"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_files = FileList["spec/**/*_spec.rb"]
  end
  task :default => :spec

rescue LoadError
  puts "RSpec (or a dependency) not available. Run: bundle install"
end

namespace :gem do
  def gem_name
    "to_api-#{eval(File.read('to_api.gemspec')).version}.gem"
  end

  desc "Build the gem"
  task :build do
    mkdir_p "pkg", :verbose => false
    sh "gem build to_api.gemspec && mv #{gem_name} pkg"
  end
  
  desc "Release the gem"
  task :release => :build do
    sh "gem push pkg/#{gem_name}"
  end
end

