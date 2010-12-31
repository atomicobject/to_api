require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

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