# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "to_api/version"

Gem::Specification.new do |s|
  s.name        = "to_api"
  s.version     = ToApi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Shawn Anderson", "Ryan Fogle"]
  s.email       = ["shawn42@gmail.com", "github@atomicobject.com"]
  s.homepage    = "http://github.com/atomicobject/to_api"
  s.summary     = %q{Helper for simplifying JSON api creation}
  s.description = %q{Helper for simplifying JSON api creation.}

  s.rubyforge_project = "to_api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "activerecord", ["3.2.15"]
  # s.add_development_dependency "activerecord", [">= 2.3", "< 3"]
  s.add_development_dependency "rspec", "= 2.14.1"
  s.add_development_dependency "rake", ">= 0.8.7"
  s.add_development_dependency "pry"
  s.add_development_dependency "sqlite3"
end
