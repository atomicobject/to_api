Gem::Specification.new do |s|
  s.name = %q{to_api}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shawn Anderson", "Ryan Fogle"]
  s.date = %q{2010-12-10}
  s.description = %q{Helper for simplifying JSON api creation.}
  s.email = %q{shawn42@gmail.com}
  s.homepage = %q{http://github.com/atomicobject/to_api}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{to_api}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Helper for simplifying JSON api creation}
  s.files = Dir["{bin,lib}/**/*"] + %w(README)
  s.test_files = Dir['{spec,test}/**/*.rb']

  s.add_dependency "activerecord", [">= 2.3", "< 3"]
  s.add_development_dependency "rspec", "= 1.3.1"
  s.add_development_dependency "rake", ">= 0.8.7"
end

