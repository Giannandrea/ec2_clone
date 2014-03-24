Gem::Specification.new do |s|
  s.name = %q{ec2_clone}
  s.version = "0.1.1"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ['Annalisa Bacherotti','Mauro Giannandrea']
  s.date = %q{2014-03-21}
  s.description = %q{clone ec2 instance and launch image created}
  s.email = %q{rubyteam@navionics.com}
  s.files = ["Rakefile", "ec2_clone.gemspec", "lib/check_poller.rb", "lib/ec2_clone.rb", "test/test_ec2_clone.rb", "test/test_helper.rb"]
  s.has_rdoc = false
  s.homepage = %q{}
  s.require_paths = ["lib"]
  s.license = "MIT"
  s.rubygems_version = %q{0.5.0}
  s.summary = %q{clone ec2 instance and launch image created, useful to create scripts to automate tests on production clones}
  s.add_dependency(%q<capistrano>, [">= 2.0.0"])
  s.add_dependency(%q<aws-sdk>, [">= 1.31.3"]) 
  s.add_dependency(%q<builder>, [">= 2.1.2"])
end
