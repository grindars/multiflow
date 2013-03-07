# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "multiflow"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2")
  s.authors = ["Ryan Oberholzer", "Sergey Gridasov"]
  s.date = "2013-03-06"
  s.description = "State machine that allows dynamic transitions for business workflows"
  s.email = ["ryan@platform45.com", "grindars@gmail.com"]
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.homepage = "https://github.com/grindars/multiflow"
  s.rubygems_version = "2.0.0"
  s.summary = "State machine that allows dynamic transitions for business workflows"

  s.add_runtime_dependency("activesupport", ">= 0")
  s.add_development_dependency("rspec", ">= 2.0.0")
  s.add_development_dependency("activerecord", ">= 0")
  s.add_development_dependency("mongoid", ">= 2.0.0.beta.20")
  s.add_development_dependency("sqlite3-ruby", ">= 0")
end
